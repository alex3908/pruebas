# frozen_string_literal: true

class Client < ApplicationRecord
  include Filterable, HubspotConcern
  include SuppressionEmailConcern
  include DocumentConcern

  GENDER = { MALE: "male", FEMALE: "female" }
  MORAL = "moral"
  PHYSICAL = "physical"

  attr_accessor :source

  enum origin: { inbound: 0, cartera: 1 }

  belongs_to :user, required: false
  has_one :user_client, required: false

  belongs_to :lead_source, required: false
  has_one :physical_client, class_name: "PhysicalClient", foreign_key: "client_id"
  has_one :moral_client, class_name: "MoralClient", foreign_key: "client_id"
  has_many :log, class_name: "Log", foreign_key: "element_id"
  has_many :quote_logs, dependent: :destroy
  has_many :cash_backs, dependent: :destroy
  has_many :cash_flows, dependent: :destroy
  has_many :documents, as: :documentable
  has_many :client_users
  has_many :users, through: :client_users
  has_many :referred_clients
  has_many :reference_contacts

  has_one_attached :official_identification
  has_one_attached :curp
  has_one_attached :address_proof
  has_one_attached :constitutional_act
  has_one_attached :fiscal_act
  has_one_attached :birth_certificate

  accepts_nested_attributes_for :documents

  delegate :city, :country, :postal_code, :state, :colony, :street, :location, :house_number, :interior_number, to: :get_person, allow_nil: true
  delegate :has_activity?, to: :user_client, allow_nil: true

  validates :name, presence: true
  validates :first_surname, presence: true, if: :physical?
  validates :email, presence: true
  validates :email, uniqueness: true
  validate :validate_client_exists_on_hubspot
  validate :phone_format_verification
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]

  after_create :clone_to_hubspot
  after_create :create_documents
  after_create :create_client_user
  after_create :send_automated_email
  before_save :lowercase_email
  after_update :binnacle
  after_update :update_documents, if: :person_previously_changed?
  after_update :create_user_for_mobile

  after_create :send_email_confirmation_instructions, if: :confirm_email?
  after_update :validate_email_update, if: :email_previously_changed?

  search_scope :user_id, -> (id) {
    where(user_id: id)
  }

  scope :autocomplete, -> (search) {
    where("LOWER(CONCAT(name,' ',first_surname, ' ' ,second_surname)) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?)", "%#{search}%", "%#{search}%")
    .select("id, CONCAT(name,' ',first_surname,' ',second_surname,' (',email,')') as value")
  }

  def self.search(params)
    clients = Client.all
    clients = clients.where("LOWER(CONCAT(name,' ',first_surname,' ',second_surname)) LIKE LOWER(?)", "%#{params[:search_name].tr(" ", "%")}%") if params[:search_name].present?
    clients = clients.where("LOWER(email) LIKE LOWER(?)", "%#{params[:search_email]}%".delete(" \t\r\n")) if params[:search_email].present?
    clients = clients.where(client_users: { user_id: User.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email_seller]}%".delete(" \t\r\n")) }) if params[:email_seller].present?
    clients = clients.where(client_users: { user_id: User.where("LOWER(CONCAT(first_name,' ',last_name)) LIKE LOWER(?)", "%#{params[:name_seller].tr(" ", "%")}%") }) if params[:name_seller].present?
    clients
  end

  def self.default_client_concept
    ClientUserConcept.sales_executive
  end

  def sales_executive
    client_user = client_users.where(client_user_concept: self.class.default_client_concept).first
    return client_user.user if client_user.present?
    nil
  end

  def sign_label
    self.person == "physical" ? "cliente" : "representante legal"
  end

  def address_attributes
    {
      country: transliterate(country),
      postal_code: postal_code&.gsub(/[^.0-9]+/, ""),
      state: transliterate(state),
      city: transliterate(city),
      colony: transliterate(colony),
      street: transliterate(street),
      location: transliterate(location),
      house_number: transliterate(house_number),
      interior_number: transliterate(interior_number)
    }
  end

  def get_person
    if person == "physical"
      physical_client || nil
    elsif person == "moral"
      moral_client || nil
    end
  end

  def formatted_phone(phone)
    if phone.present?
      phone = phone.gsub(/[^.0-9]+/, "")
      "+#{phone}"
    end
  end

  def formatted_main_phone
    formatted_phone(main_phone)
  end

  def formatted_optional_phone
    formatted_phone(optional_phone)
  end

  def phone_format_verification
    if self.main_phone.present?
      if self.main_phone.length < 10
        errors.add(:main_phone, I18n.t("errors.models.client.main_phone.wrong_format"))
      end
    end

    if self.optional_phone.present?
      optional = self.optional_phone
      if optional.length < 10
        errors.add(:optional_phone, I18n.t("errors.models.client.optional_phone.wrong_format"))
      else
        self.optional_phone = optional
      end
    end
  end

  def label(short = false)
    return "#{name} #{first_surname}#{short ? "" : " " + (second_surname || "")}" if self.physical?
    self.name if self.moral?
  end

  def sign_tag
    label.parameterize.underscore
  end

  def get_gender
    return "Femenino" if self.gender == "female"
    "Masculino" if self.gender == "male"
  end

  def get_prefix(prefix)
    return self.gender == "female" ? "a la señora" : "al señor" if prefix == "first_format"
    self.gender == "female" ? "La señora" : "El señor" if prefix == "second_format"
  end

  def folders
    Folder.where("client_id = :id OR client_2_id = :id OR client_3_id = :id OR client_4_id = :id OR client_5_id = :id OR client_6_id = :id", id: self.id)
  end

  def finalized_folders
    folders.where.not(approved_date: nil)
  end

  def cash_back_available(folder_id = nil, opts = {})
    available_cash_back = self.cash_backs.active
    available_cash_back = available_cash_back.where(payment_method_id: opts[:payment_method].id) if opts[:payment_method].present?

    if folder_id.present?
      filtered_cash_back = available_cash_back.where(exclusive_folder_id: folder_id)
      filtered_cash_back = filtered_cash_back + available_cash_back.where(exclusive_folder_id: nil) unless opts[:only_exclusive_cash_backs] || opts[:payment_method]&.cash_back_folder_exclusivity?
    end

    filtered_cash_back.inject(0) do |sum, cash_back|
      if cash_back.cash_back_flows.empty?
        add_to_available_cash = (cash_back.amount || 0)
      else
        add_to_available_cash = (cash_back.cash_back_flows.last_balance || 0)
      end

      sum + add_to_available_cash
    end
  end

  def physical?
    self.person == PHYSICAL
  end

  def moral?
    self.person == MORAL
  end

  def is_mexican
    if moral?
      moral_client&.country.nil? || moral_client&.country == "México"
    else
      physical_client&.nationality.nil? || physical_client&.nationality == "Mexicano" || physical_client&.nationality == "Mexicana"
    end
  end

  def is_foreign
    !is_mexican
  end

  def get_person_type
    if self.person == Client::PHYSICAL
      PhysicalClient.model_name.human
    else
      MoralClient.model_name.human
    end
  end

  def send_email_confirmation_instructions
    ClientMailer.send_email_confirmation(self).deliver_later
  end

  def self.autocomplete_by_email(email)
    find_by("lower(email) = lower(?)", email)
  end

  def assignation_date
    client_users.first.created_at.strftime("%d/%m/%Y")
  end

  private

    def confirm_email?
      Setting.find_by_key("client_confirmation").try(:convert)
    end

    def create_documents
      documents_for(DocumentTemplate.for_physical_clients) if self.physical?
      documents_for(DocumentTemplate.for_moral_clients) if self.moral?
      documents_for(DocumentTemplate.for_general_clients)
    end

    def documents_for(document_templates)
      document_templates.find_each do |template|
        self.documents.create(document_template_id: template.id)
      end
    end

    def update_documents
      # Destroy empty documents (except general).
      self.documents
      .joins(:document_template)
      .where.not("document_templates.client_type = (?)", DocumentTemplate::GENERAL)
      .each do |document|
        document.destroy unless document.attached?
      end
      # Create documents that does not exist on current client.
      create_new_documents(DocumentTemplate.for_general_clients) # This updates general files.
      create_new_documents(DocumentTemplate.for_physical_clients) if self.physical?
      create_new_documents(DocumentTemplate.for_moral_clients) if self.moral?
    end

    def create_new_documents(documents)
      # Get id's of remaining documents
      current_docs = self.documents.pluck(:document_template_id)
      documents.where.not(id: current_docs).find_each do |template|
        self.documents.create(document_template_id: template.id)
      end
    end

    def validate_client_exists_on_hubspot
      return if is_not_hubspot_enabled? || self.persisted?
      contact = Hubspot::Contact.find_by_email(self.email)
      owner = Hubspot::Owner.find_by_email(Current.user)

      if same_owner(contact, owner)
        errors.add(:email, "Este cliente ya se encuentra registrado en hubspot")
      end
    rescue Hubspot::RequestError => eh
      Bugsnag.notify(eh)
    end

    def clone_to_hubspot
      return if is_not_hubspot_enabled?
      contact = Hubspot::Contact.find_by_email(self.email)
      owner = Hubspot::Owner.find_by_email(self.client_users.first.user)
      if contact.nil? && owner.present?
        Hubspot::Contact.create!(self.client.email, firstname: self.client.name, lastname: self.client.first_surname, hubspot_owner_id: owner.owner_id)
      end
    rescue
    end

    def lowercase_email
      self.email.downcase!
    end

    def binnacle
      if Current.user.present?
        filtered_changes = previous_changes
        previous_changes.keys.each do |attr_name, attr_value|
          if previous_changes[attr_name][0].nil?
            filtered_changes[attr_name][0] = ""
          end

          if previous_changes[attr_name][1].nil?
            filtered_changes[attr_name][1] = ""
          end
        end
        element_changes = "#{filtered_changes.except(:updated_at)}".gsub("=>", ":")

        if element_changes != "{}"
          @log = {
              date: Time.zone.now,
              element_changes: element_changes,
              element: "client",
              element_id: self.id,
              user_id: Current.user.id
          }

          Log.create(@log)
        end
      end
    end

    def transliterate(param)
      return nil if param.nil?

      I18n.transliterate(param)
    end

    def validate_email_update
      self.update(confirmed_email: false)
      self.send_email_confirmation_instructions
    end

    def create_client_user
      client_users.create(user: Current.user, client_user_concept: self.class.default_client_concept)
    end

    def send_automated_email
      AutomatedEmail.where(
        automated_type: AutomatedEmail.types[:clients],
        execution_type: [source, AutomatedEmail.sources[:all_sources]]
      ).each do |enter_email|
        AutomatedEmailMailer.send_automated_email(self, enter_email).deliver_later(wait_until: enter_email.delivery_in.days.from_now)
      end
    end

    def create_user_for_mobile
      UserClient.create!(
        email: email,
        password: "adaratest",
        password_confirmation: "adaratest"
      )
    rescue StandardError => ex
      Bugsnag.notify(ex)
    end
end
