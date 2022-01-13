# frozen_string_literal: true

class User < ApplicationRecord
  include Rails.application.routes.url_helpers, DeviseInvitable::Inviter, Filterable
  include SuppressionEmailConcern

  delegate :can?, :cannot?, to: :ability

  MAX_BRANCHES = 10
  EVO_COMMISSION = 1

  GENDER = { male: "male", female: "female" }

  scope :with_parent, ->(parent) { to_a.select { |u| next if u.structure.nil?; u.structure.parent == parent } }
  scope :permitted, ->(is_permitted) { is_permitted ? all : joins(:role).where("roles.hidden = (?)", false) }

  validates :email, presence: true
  validates :email, uniqueness: true
  validate :phone_format_verification
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  has_many :frequent_questions

  has_one :invited, class_name: "Referent", foreign_key: "invited_id"
  has_one :structure, class_name: "Structure", foreign_key: "user_id"
  has_many :clients, class_name: "Client", foreign_key: "user_id"
  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  has_many :stage_users, dependent: :destroy
  has_many :stages, through: :stage_users
  has_many :users
  has_many :folder, class_name: "Folder", foreign_key: "user_id"
  has_many :referrer, class_name: "Referent", foreign_key: "referrer_id"
  has_many :file_approvals, as: :approvable
  has_many :bank_accounts, as: :payable
  has_many :quote_logs, dependent: :destroy
  has_many :step_logs
  has_many :folder_users, -> { visible }
  has_many :folders, through: :folder_users
  has_many :client_users
  has_many :clients, through: :client_users
  has_many :penalties
  has_many :api_keys
  has_many :digital_signature_logs
  has_many :user_announcements
  has_many :announcements, through: :user_announcements
  has_many :classifier_users
  has_many :classifiers, through: :classifier_users

  has_one_attached :avatar
  has_one_attached :official_identification
  has_one_attached :curp
  has_one_attached :address_proof
  has_one_attached :rfc
  has_one_attached :birth_certificate
  has_one_attached :non_criminal_record
  has_one_attached :job_reference
  has_one_attached :recommendation_letter_1
  has_one_attached :recommendation_letter_2

  accepts_nested_attributes_for :bank_accounts
  accepts_nested_attributes_for :structure

  FILES_WITH_APPROVAL = [:official_identification, :curp, :address_proof, :rfc, :birth_certificate,
                         :non_criminal_record, :job_reference, :recommendation_letter_1, :recommendation_letter_2]

  belongs_to :branch
  belongs_to :role

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable, :invitable

  before_create :set_activation_date
  before_update :deactivating_updates_disabled_at, if: :is_active_changed?
  after_save :set_file_approvals

  before_save :lowercase_email
  after_update :binnacle

  scope :with_permission, -> (_permission) { joins(role: :permissions).where("permissions.id": _permission) }
  scope :can_reserve, -> () { joins(role: :permissions).where("permissions.subject_class": ":quote", "permissions.action": "reserve") }
  scope :active, -> () { where(is_active: true) }
  scope :autocomplete, -> (search) {
    where("LOWER(CONCAT(first_name,' ',last_name)) LIKE LOWER(?) OR LOWER(email) LIKE LOWER(?)", "%#{search}%", "%#{search}%")
        .select("users.id as id,CONCAT(first_name,' ',last_name,' (',email,')') as value")
  }

  scope :without_structure, -> () { joins(:role).left_joins(:structure).where("is_active = ? OR roles.level IS NOT NULL", false).where(structures: { id: nil }) }

  def self.search(params)
    users = User.all
    users = users.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n")) if params[:email].present?
    users = users.where(role_id: params[:role]) if params[:role].present?
    users = users.where(branch_id: params[:branch]) if params[:branch].present?
    users = users.where("LOWER(CONCAT(first_name,' ',last_name)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%") if params[:name].present?
    users = users.where(is_active: params[:status].to_sym == :active) if params[:status].present?
    users
  end

  def self.set_params(params, sort_column, sort_direction)
    search(params).order(sort_column + " " + sort_direction)
  end

  def self.set_leader(level)
    case level
    when "vice_director"
      Director
    when "manager"
      ViceDirector
    when "coordinator"
      Manager
    when "salesman"
      Coordinator
    end
  end

  def closed_deals
    if self.structure.present?
      Folder.where("user_id = (?) and status = (?) and step_id = (?) and approved_date >= (?)", self.id, :active, Step.last_step.id, self.structure.created_at.to_date)
    else
      Folder.where(user: self, status: :active, step: Step.last_step)
    end
  end

  def file_approve(key)
    self.file_approvals.find_by(key: key.to_s, approvable_type: "User")
  end

  def set_file_approvals
    FILES_WITH_APPROVAL.each do |file|
      self.file_approvals.find_or_create_by!(key: file.to_s) if self.public_send(file.to_s).attached?
    end
  end


  def principal_bank_account
    bank_accounts.where(principal: true).take
  end

  def phone
    if super.present?
      main = super.gsub(/[^.0-9]+/, "")
      "(#{main[0..2]}) #{main[3..5]} #{main[6..]}"
    end
  end

  def phone_format_verification
    if self.phone.present?
      main = self.phone.gsub(/[^.0-9]+/, "")
      if main.length < 10
        errors.add(:phone, I18n.t("errors.models.user.phone.wrong_format"))
      else
        self.phone = main
      end
    end
  end

  def headers_for(action)
    return {} unless invited_by && action == :invitation_instructions
    { subject: t("devise.mailer.invitation_instructions.subject", brand: @company_name) }
  end

  def get_gender
    return "Femenino" if self.gender == "female"
    "Masculino" if self.gender == "male"
  end

  def lowercase_email
    self.email.downcase!
  end

  def active_for_authentication?
    super && self.is_active?
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def referrer?
    Referent.where(invited_id: self.id).first
  end

  def set_folder_counter
    if self.ability.can?(:read, Folder)
      folder_permissions = set_folder_permissions
      @folder_count = Folder.where(status: folder_permissions).count
    else
      @folder_count = 0
    end


    if @folder_count > 99
      "99+"
    else
      @folder_count
    end
  end

  def set_folder_permissions
    folder_permissions = []

    folder_permissions.push(Folder::STATUS[:ACTIVE]) if can? :reserve, :quote

    folder_permissions
  end

  def label
    "#{first_name} #{last_name}"
  end

  def label_with_role
    "#{first_name} #{last_name} (#{role.name})"
  end

  def label_with_branch
    label = "#{first_name} #{last_name} "
    if branch.present?
      return label + "(#{branch.name})"
    end

    label.strip
  end

  def label_with_email
    "#{first_name} #{last_name} (#{email})"
  end

  def role?(base_role)
    base_role == self.role.key
  end

  def image_nil
    if self.avatar.attached?
      rails_blob_path(self.avatar, disposition: "attachment", only_path: true)
    else
      "base-avatar.png"
    end
  end

  def binnacle
    unless Current.user.nil?
      filtered_changes = previous_changes
      previous_changes.keys.each do |attr_name, attr_value|
        if previous_changes[attr_name][0].nil?
          filtered_changes[attr_name][0] = ""
        end

        if previous_changes[attr_name][1].nil?
          filtered_changes[attr_name][1] = ""
        end
      end

      if filtered_changes[:birthdate].present?
        filtered_changes[:birthdate][0] = filtered_changes[:birthdate][0].strftime("%m-%d-%Y") unless filtered_changes[:birthdate][0].blank?
        filtered_changes[:birthdate][1] = filtered_changes[:birthdate][1].strftime("%m-%d-%Y") unless filtered_changes[:birthdate][1].blank?
      end

      if filtered_changes[:disabled_at].present?
        filtered_changes[:disabled_at][0] = filtered_changes[:disabled_at][0].strftime("%m-%d-%Y") unless filtered_changes[:disabled_at][0].blank?
        filtered_changes[:disabled_at][1] = filtered_changes[:disabled_at][1].strftime("%m-%d-%Y") unless filtered_changes[:disabled_at][1].blank?
      end

      if filtered_changes[:activated_at].present?
        filtered_changes[:activated_at][0] = filtered_changes[:activated_at][0].strftime("%m-%d-%Y") unless filtered_changes[:activated_at][0].blank?
        filtered_changes[:activated_at][1] = filtered_changes[:activated_at][1].strftime("%m-%d-%Y") unless filtered_changes[:activated_at][1].blank?
      end

      element_changes = "#{filtered_changes.except(:updated_at,
                                                   :reset_password_token,
                                                   :reset_password_sent_at,
                                                   :remember_created_at,
                                                   :invitation_token,
                                                   :invitation_created_at,
                                                   :invitation_sent_at,
                                                   :invitation_accepted_at,
                                                   :invitation_limit,
                                                   :invited_by_id,
                                                   :invited_by_type,
                                                   :created_by,
                                                   :encrypted_password)}".gsub("=>", ":")

      if element_changes != "{}"
        @log = {
            date: Time.zone.now,
            element_changes: element_changes,
            element: "user",
            element_id: self.id,
            user_id: Current.user.id
        }

        Log.create(@log)
      end
    end
  end

  def has_structure?
    structure.present?
  end

  def merge(user)
    self.structure = user.structure
    self.client = user.client
    self.project_users = user.project_users
    self.stage_users = user.stage_users
    self.folder_users = user.folder_users
    self.folder = user.folder
    self.referrer = user.referrer
    self.file_approvals = user.file_approvals
    self.bank_accounts = user.bank_accounts
    self.quote_logs = user.quote_logs
    self.penalties = user.penalties
    self.api_keys = user.api_keys
    self.branch = user.branch

    self.save
  end

  def folders
    if structure.present? && ability.can?(:read_subordinate_folders, Folder)
      sale_concept = FolderUserConcept.find_by_key(:sale)
      user_ids = structure.subtree.pluck(:user_id)
      user_ids << self.id

      Folder.joins(:folder_users).where(folder_users: { user_id: user_ids, folder_user_concept: sale_concept }).or(Folder.joins(:folder_users).where(folder_users: { id: folder_user_ids })).distinct
    else
      Folder.joins(:folder_users).where(folder_users: { id: folder_user_ids })
    end
  end

  def subordinates
    subordinate_users = []
    subordinate_role = self.role.next
    if subordinate_role.present?
      subordinate_users = Structure.find_by(user_id: self.id).descendants.where(role: subordinate_role).where.not(user: nil)
      subordinate_users = subordinate_users.map { |structure| { id: structure.user.id, name: structure.user.label } }
    else
      subordinate_users = Structure.find_by(user_id: self.id).children.where.not(user: nil)
      subordinate_users = subordinate_users.map { |structure| { id: structure.user.id, name: structure.user.label } }
    end
    subordinate_users
  end

  def set_activation_date
    self.activated_at = Time.zone.now.to_datetime
  end

  def deactivating_updates_disabled_at
    is_active_changes = changes[:is_active]
    if is_active_changes.first == false && is_active_changes.second == true
      self.activated_at = Time.zone.now.to_datetime
    else
      self.disabled_at = Time.zone.now.to_datetime
    end
  end
end
