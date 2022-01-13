# frozen_string_literal: true

class Folder < ApplicationRecord
  include Filterable, FolderActionsConcern, CommissionsHelper, FoldersHelper, PaymentsHelper, HubspotConcern, InstallmentConcern, PurchaseConditionsConcern, FolderPayActionsConcern, DocumentConcern
  delegate :active_mails, to: :stage
  scope :not_in_sale, ->() { where.not(status: ["expired", "canceled"]) }

  scope :sold_immediate_construction, ->() do
    not_in_sale.joins(:payment_scheme).where("payment_schemes.immediate_extra_months > ?", 0)
  end

  STATUS = { ACTIVE: "active", REJECTED: "rejected", REVISION: "revision", ACCEPTED: "accepted", EXPIRED: "expired", APPROVED: "approved", CANCELED: "canceled" }
  BUYER = { OWNER: "owner", COOWNER: "coowner" }

  enum status: { active: "active", expired: "expired", canceled: "canceled" }
  enum buyer: { owner: "owner", coowner: "coowner" }

  HUBSPOT = {
      APPOINTMENT_SCHEDULED: Rails.application.secrets.hubspot_appointmentscheduled,
      WON: Rails.application.secrets.hubspot_closedwon,
      PIPELINE: Rails.application.secrets.hubspot_pipeline,
      LOST: Rails.application.secrets.hubspot_closedlost
  }

  delegate :credit_scheme, to: :payment_scheme

  belongs_to :lot
  belongs_to :step, optional: true, counter_cache: true
  belongs_to :user
  belongs_to :canceled_by, class_name: "User", foreign_key: "canceled_by", optional: true
  belongs_to :client, class_name: "Client", foreign_key: "client_id"
  belongs_to :client_2, class_name: "Client", foreign_key: "client_2_id", optional: true
  belongs_to :client_3, class_name: "Client", foreign_key: "client_3_id", optional: true
  belongs_to :client_4, class_name: "Client", foreign_key: "client_4_id", optional: true
  belongs_to :client_5, class_name: "Client", foreign_key: "client_5_id", optional: true
  belongs_to :client_6, class_name: "Client", foreign_key: "client_6_id", optional: true
  belongs_to :contract, required: false

  has_many :online_payment_tickets
  has_many :installments, -> { active }, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :evaluation_folders
  has_many :evaluations, through: :evaluation_folders
  has_many :step_logs, -> { created_at_asc }, dependent: :destroy
  has_many :cash_flows
  has_many :folder_users
  has_many :users, through: :folder_users
  has_many :documents, dependent: :destroy, as: :documentable
  has_many :support_sales
  has_many :subscriptions
  has_many :digital_signatures
  has_one :payment_scheme, autosave: true
  has_one :quote_log

  accepts_nested_attributes_for :evaluation_folders
  accepts_nested_attributes_for :documents
  accepts_nested_attributes_for :payment_scheme
  accepts_nested_attributes_for :installments

  validate :liquid_format
  validate :check_if_step_blocked, if: :will_save_change_to_step_id?

  after_create :schedule_expirations
  after_create :create_deal
  after_create :create_documents
  after_create :create_installments
  after_create :set_folder_users, if: :ready_for_folder_users?

  after_update :binnacle, :close_deal, :save_expiration_date
  after_update :update_folder_owners, if: :folder_owner_updated?
  after_update :save_commission_amount, if: :is_folder_approved?
  after_update :save_approved_date, if: :save_approved_date?
  after_update :delete_installments_without_payments, if: :canceled?
  after_update :remove_coupon, if: proc { |folder| folder.canceled? || folder.expired? }

  after_save :step_logger
  after_save :set_lot_status

  before_validation on: :create do
    self.start_date = DateTime.now if self.start_date.nil?
    self.step = Step.first_step
    self.ready = true # TODO: Remove this line in the Rosavento deploy
  end

  def self.set_params(params, sort_column = "folders.id", sort_direction = "desc")
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    folders = joins(:client, user: :branch, lot: { stage: { phase: :project } })
    folders = folders.where(client_id: Client.where("LOWER(CONCAT(name, first_surname, second_surname)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:name].present?
    folders = folders.where(client_id: Client.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n"))) if params[:email].present?
    folders = folders.where(lot_id: Lot.where(number: params[:lot_number].delete(" \t\r\n"))) if params[:lot_number].present?
    folders = folders.where(lot_id: Lot.where("LOWER(label) = LOWER(?)", params[:lot_label].delete(" \t\r\n"))) if params[:lot_label].present?
    folders = folders.where(status: params[:status]) if params[:status].present?
    folders = folders.where(step_id: params[:step]) if params[:step].present?
    status_blank = params[:status].blank? || params[:status].nil?
    without_hidden = params[:with_hidden].blank? || params[:with_hidden].nil? || params[:with_hidden].present? && !params[:with_hidden]
    folders = folders.where.not(status: [Folder::STATUS[:CANCELED], Folder::STATUS[:EXPIRED]]) if status_blank && without_hidden
    folders = folders.where("projects.id" => params[:project]) if params[:project].present?
    folders = folders.where("phases.id" => params[:phase]) if params[:phase].present?
    folders = folders.where("stages.id" => params[:stage]) if params[:stage].present?
    folders = folders.joins(:folder_users).where("folder_users.user_id" => params[:user]) if params[:user].present?
    folders = folders.joins(:folder_user_concepts).where("folder_user_concepts.id" => params[:folder_user_concept_id]) if params[:ftolder_user_concept_id].present?
    folders = folders.where("branches.id" => params[:branch]) if params[:branch].present?
    folders = folders.where("folders.id" => params[:folio]) if params[:folio].present?
    folders = folders.where(user_id: User.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:salesman].tr(" ", "%")}%")) if params[:salesman].present?
    level_filter = last_level_selected(params)
    folders = folders.where(user_id: level_filter).or(folders.where("EXISTS ( SELECT * FROM folder_users WHERE folder_users.folder_id = folders.id AND user_id = ?)", level_filter)) if level_filter.present?
    folders = folders.where("folders.start_date BETWEEN ? and ?", params[:from_date].to_time.strftime("%Y-%m-%d %l:%M:%S"), params[:to_date].to_time.strftime("%Y-%m-%d %l:%M:%S")) if params[:from_date].present? && params[:to_date].present?
    folders = folders.where("folders.approved_date BETWEEN ? and ?", params[:approved_from_date].to_time.strftime("%Y-%m-%d %l:%M:%S"), params[:approved_to_date].to_time.strftime("%Y-%m-%d %l:%M:%S")) if params[:approved_from_date].present? && params[:approved_to_date].present?
    folders = folders.where("folders.approved_date BETWEEN ? and ?", params[:approved_date_from_date].to_time.strftime("%Y-%m-%d %l:%M:%S"), params[:approved_date_to_date].to_time.strftime("%Y-%m-%d %l:%M:%S")) if params[:approved_date_from_date].present? && params[:approved_date_to_date].present?
    folders
  end

  def self.last_level_selected(params)
    roles = {}
    leaders = []
    params.each do |key, value|
      next unless (key.include? "_node") && value.present?
      key = key.gsub("_node", "")
      leaders.push(key)
      roles[key] = value
    end

    return nil if leaders.empty?
    last_level = Role.where(key: leaders).order(level: :asc).last&.key
    roles[last_level]
  end

  def save_commission_amount
    quotation = self.generate_quote
    self.folder_users.each do |commission|
      amount = quotation.total_with_discount * (commission.percentage / 100)
      commission.update(amount: amount.round(2))
    end
  end

  def save_expiration_date
    if previous_changes[:status].present? && previous_changes[:status][1] == STATUS[:EXPIRED]
      self.update_columns(expiration_date: Time.zone.now)
      self.lot.update(status: Lot::STATUS[:FOR_SALE])
    end
  end

  def get_restructures(hidden_payment = Payment.new)
    capital_payments = []
    payment_with_capital = Payment.joins(:restructure).where(installment: self.installments, status: Payment::STATUS[:ACTIVE]).where.not(restructure: nil).order(created_at: :ASC)
    payment_with_capital.each do |payment|
      term = payment.installment.number.to_i
      term += (self.payment_scheme.start_installments || 0) if Restructure.down_payment_concept?(payment.restructure.concept) && payment.installment.concept == Installment::CONCEPT[:FINANCING]

      unless payment == hidden_payment
        capital_payments << {
            folder_id: self.id,
            installment_number: term.to_i,
            capital_paid: payment.amount,
            concept: payment.restructure.concept,
            current_term: payment.restructure.current_term,
            current_discount: payment.restructure.current_discount,
            current_day: payment.restructure.current_day,
            grace_months: payment.restructure.grace_months,
            delay_months: payment.restructure.delay_months,
            without_promotions: payment.restructure.without_promotions
        }
      end
    end

    capital_payments
  end

  # TODO: Show only the answers of the last evaluation
  def rejected_evaluations
    evaluation_folders.joins(:evaluation).where("evaluations.question_type = 'reject' AND evaluation_folders.answer = 'Si'")
  end

  def create_deal
    return if is_not_hubspot_enabled?
    quotation = self.generate_quote

    contact = Hubspot::Contact.find_by_email(self.client.email)
    hubspot_owner = Hubspot::Owner.find_by_email(self.user.email)

    if hubspot_owner.present?
      contact = Hubspot::Contact.create!(self.client.email, firstname: self.client.name, lastname: self.client.first_surname) if contact.nil?

      deal_name = Setting.find_by(key: "deal-name")&.value || "Orve-CRM"
      begin
        deal = Hubspot::Deal.create!(nil, [], contact.vid,
                                     dealname: "#{deal_name}: #{contact[:firstname]} #{contact[:lastname]}",
                                     dealstage: HUBSPOT[:APPOINTMENT_SCHEDULED],
                                     amount: quotation.total_with_discount,
                                     pipeline: HUBSPOT[:PIPELINE],
                                     closedate: Date.today.strftime("%Q"),
                                     hubspot_owner_id: hubspot_owner.owner_id
        )

        update_column(:deal, deal.deal_id)
      rescue Exception => he
        Bugsnag.notify(he)
        flash[:error] = "Ocurrió un problema al crear el negocio en Hubspot."
      end
    else
      puts "hubspot_owner not found"
    end
  rescue Exception => ex
    Bugsnag.notify(ex)
    puts ex.message
    puts folder.id
  end

  def close_deal
    if deal_not_created && is_hubspot_enabled?
      deal = Hubspot::Deal.find(self.deal)
      if self.finished?
        deal.update!(dealstage: HUBSPOT[:WON])
      elsif self.canceled? || self.expired?
        deal.update!(dealstage: HUBSPOT[:LOST])
      end
    end
  rescue Exception => ex
    Bugsnag.notify(ex)
  end

  def not_finished?
    active? && !finished?
  end

  def not_active?
    canceled? || expired?
  end

  def ready_for_folder_users?
    (self.user.can?(:reserve, :quote) || self.user.structure.present?) && self.folder_users.empty?
  end

  def set_folder_users
    create_folder_users(self)
  end

  def calc_date
    return self.start_date if self.start_date.present?
    return self.created_at if self.created_at.present?

    Time.zone.now
  end

  def status_label
    statuses = {
        STATUS[:ACTIVE] => "Activo",
        STATUS[:EXPIRED] => "Expirado",
        STATUS[:CANCELED] => "Cancelado",
    }

    return step.name if active?
    statuses[self.status]
  end

  def total_down_payment
    self.payment_scheme.initial_payment + self.payment_scheme.down_payment
  end

  def down_payment_percentage
    total_amount = total_sale.present? ? total_sale : installments.pluck(:total).sum(&:to_f)
    total_down_payment / total_amount
  end

  def next_step
    self.step.next_step if self.active? && self.step.present?
  end

  def required_documents_progress
    docs = required_documents(self, next_step)
    filled_docs = docs.select { |doc| !doc[:missing?] }

    "#{filled_docs.count}/#{docs.count}"
  end

  def buyer_label
    self.owner? ? "Propietario" : "Copropietario"
  end

  def clients
    clients = [client]
    clients << client_2 if client_2.present?
    clients << client_3 if client_3.present?
    clients << client_4 if client_4.present?
    clients << client_5 if client_5.present?
    clients << client_6 if client_6.present?
    clients
  end

  def binnacle
    if Current.user.present? || previous_changes[:expiration_date].present?
      filtered_changes = previous_changes
      previous_changes.keys.each do |attr_name, attr_value|
        if previous_changes[attr_name][0].nil?
          filtered_changes[attr_name][0] = ""
        end

        if previous_changes[attr_name][1].nil?
          filtered_changes[attr_name][1] = ""
        end
      end

      if filtered_changes[:start_date].present?
        filtered_changes[:start_date][0] = filtered_changes[:start_date][0].strftime("%m-%d-%Y") unless filtered_changes[:start_date][0].blank?
        filtered_changes[:start_date][1] = filtered_changes[:start_date][1].strftime("%m-%d-%Y") unless filtered_changes[:start_date][1].blank?
      end

      if filtered_changes[:approved_date].present?
        filtered_changes[:approved_date][0] = filtered_changes[:approved_date][0].strftime("%m-%d-%Y") unless filtered_changes[:approved_date][0].blank?
        filtered_changes[:approved_date][1] = filtered_changes[:approved_date][1].strftime("%m-%d-%Y") unless filtered_changes[:approved_date][1].blank?
      end

      if filtered_changes[:expiration_date].present?
        filtered_changes[:expiration_date][0] = filtered_changes[:expiration_date][0].strftime("%m-%d-%Y") unless filtered_changes[:expiration_date][0].blank?
        filtered_changes[:expiration_date][1] = filtered_changes[:expiration_date][1].strftime("%m-%d-%Y") unless filtered_changes[:expiration_date][1].blank?
      end

      if filtered_changes[:canceled_date].present?
        filtered_changes[:canceled_date][0] = filtered_changes[:canceled_date][0].strftime("%m-%d-%Y") unless filtered_changes[:canceled_date][0].blank?
        filtered_changes[:canceled_date][1] = filtered_changes[:canceled_date][1].strftime("%m-%d-%Y") unless filtered_changes[:canceled_date][1].blank?
      end

      element_changes = "#{filtered_changes.except(:updated_at,
                                                   :buy_price,
                                                   :paid,
                                                   :last_role,
      )}".gsub("=>", ":")

      if element_changes != "{}"
        @log = {
            date: Time.zone.now,
            element_changes: element_changes,
            element: "folder",
            element_id: self.id,
            user_id: Current.user&.id
        }

        Log.create(@log)
      end
    end
  end

  def parse_contract_rules(quotation)
    client_gender = self.client.gender == "male" ? 0 : 1
    lot_type = self.lot.stage.stage_type == "residential" ? 0 : 1
    client_type = self.client.person == "moral" ? 0 : 1
    client_nationality = (clients.detect { |c| c.is_foreign }.nil?) ? 0 : 1
    periods_amount = quotation.interest_payments.count
    differed_downpayment = self.payment_scheme.down_payment_finance > 1 ? 1 : 0
    financing_type = self.payment_scheme.total_payments > 1 ? 1 : 0
    total = quotation.total_with_discount
    area = lot.area

    ContractRules.new(client_gender: client_gender,
                      lot_type: lot_type,
                      client_type: client_type,
                      client_nationality: client_nationality,
                      periods_amount: periods_amount,
                      financing_type: financing_type,
                      differed_downpayment: differed_downpayment,
                      clients: clients.size,
                      area: area,
                      total: total)
  end

  def create_documents
    DocumentTemplate.for_folders.find_each do |template|
      self.documents.create(document_template_id: template.id) unless self.documents.where(document_template: template).present?
    end
  end

  def active_subscription?
    self.subscription.present? && self.subscription.active?
  end

  def last_active_payment
    Payment.where(installment_id: self.installments, status: Payment::STATUS[:ACTIVE]).order(created_at: :desc).first
  end

  def down_payment_installment_updates
    installments.down_payment.order(date: :asc).group_by(&:total).values
  end

  def financing_installment_updates
    installments.financing.order(date: :asc).group_by(&:total).values
  end

  def generate_quote(custom_payments = nil, custom_discount = nil, custom_restructures = nil)
    generate_amortization(
      price: self.payment_scheme.buy_price * area,
      area: area,
      start_date: self.lot.stage.release_date,
      date: self.calc_date,
      total_payments: custom_payments.present? ? custom_payments : self.payment_scheme.total_payments,
      down_payment_total_payments: self.payment_scheme.down_payment_finance,
      discount: custom_discount.present? ? custom_discount : self.payment_scheme.discount,
      buy_price: self.payment_scheme.buy_price,
      initial_payment: self.payment_scheme.initial_payment,
      down_payment: self.total_down_payment,
      first_payment: self.payment_scheme.first_payment,
      zero_rate: self.payment_scheme.zero_rate,
      exclusive_promotion: self.payment_scheme.promotion_discount,
      exclusive_promotion_operation: self.payment_scheme.promotion_operation,
      promotion: self.payment_scheme.promotion.present? ? self.payment_scheme.promotion.amount : 0,
      promotion_operation: self.payment_scheme.promotion.present? ? self.payment_scheme.promotion.operation : nil,
      coupon: self.payment_scheme.coupon.present? ? self.payment_scheme.coupon.promotion.amount : 0,
      coupon_operation: self.payment_scheme.coupon.present? ? self.payment_scheme.coupon.promotion.operation : nil,
      start_installments: self.payment_scheme.start_installments,
      credit_scheme: self.payment_scheme.credit_scheme.periods.order(order: :ASC),
      project_type: self.lot.stage.phase.project.quotation,
      immediate_extra_months: self.payment_scheme.immediate_extra_months,
      capital_payments: custom_restructures.present? ? custom_restructures : self.get_restructures,
      dfp: self.payment_scheme.dfp,
      relative_discount: self.lot.stage.credit_scheme.relative_discount,
      expire_months: self.lot.stage.credit_scheme.expire_months,
      relative_down_payment: self.payment_scheme.credit_scheme.relative_down_payment,
      consider_residue_in_down_payments: self.payment_scheme.credit_scheme.consider_residue_in_down_payments,
      independent_initial_payment: self.payment_scheme.independent_initial_payment,
      delivery_date: self.payment_scheme.delivery_date,
      second_payment: self.payment_scheme.second_payment,
      initial_payment_active: self.payment_scheme.initial_payment_active,
      quotation_type: self.payment_scheme.credit_scheme.quotation_type,
      with_last_payment: self.payment_scheme.with_last_payment,
      last_payment_amount: self.payment_scheme.last_payment_amount,
      is_relative_financing: self.payment_scheme.is_relative_financing
    )
  end

  def purchase_promise_document
    PurchasePromise.new(self, true)
  end

  def annexe_pld_document
    AnnexePld.new(clients, lot.stage.phase.project)
  end

  def folder_documents
    FolderDocuments.new(self, self.lot, self.lot.stage.phase, self.lot.stage, self.lot.stage.phase.project, self.generate_quote)
  end

  def amortization_table_document(with_signature_bar = true, is_digital_signature = false)
    AmortizationTable.new(self, self.lot.stage.phase.project, with_signature_bar, is_digital_signature)
  end

  def purchase_conditions_document(with_copy = true, with_signature = true)
    PurchaseConditions.new(self, with_copy, with_signature)
  end

  def account_status
    AccountStatus.new(self, user)
  end

  def contract_document
    get_document("document_template_id")
  end


  def nom_document
    get_document("document_nom_id")
  end

  def ruled_contract(quotation = nil)
    if contract.present?
      contract
    else
      quotation = generate_quote if quotation.nil?
      Contract.by_rules parse_contract_rules(quotation), lot.stage_id
    end
  end

  def has_successful_payment?(key)
    online_payment_tickets.successful.where(concept_key: key).any?
  end

  def create_installments
    quotation = self.generate_quote
    all_installments = quotation.down_payment_monthly_payments | quotation.amr

    all_installments.each_with_index do |installment, index|
      concept = installment[:concept]
      persisted_installment = Installment.find_by(folder: self, number: installment[:number], concept: concept)

      if persisted_installment.nil?
        installment_attributes = {
            number: installment[:number],
            date: installment[:date],
            down_payment: installment[:down_payment].round(2),
            total: installment[:payment].round(2),
            capital: installment[:capital].present? ? installment[:capital].round(2) : nil,
            interest: installment[:interest].present? ? installment[:interest].round(2) : nil,
            debt: installment[:amount].present? ? installment[:amount] : nil,
            folder: self,
            concept: concept
        }

        Installment.create(installment_attributes)
      end
    end
  end

  def subscription
    subs = subscriptions.order(created_at: :desc)
    subs.currently_active.take || subs.take
  end

  def paid_installments
    paid_down_payments = paid_down_payments_installments
    paid_financing = paid_financing_installments
    paid_financing + paid_down_payments
  end

  def zero_total_installments
    self.installments.where(total: 0)
  end

  def is_canceled
    status == STATUS[:CANCELED]
  end

  def first_down_payment
    self.installments.find_by(number: 1, concept: Installment::CONCEPT[:DOWN_PAYMENT])
  end

  def first_financing
    self.installments.find_by(number: 1, concept: Installment::CONCEPT[:FINANCING])
  end

  def initial_payment
    self.installments.find_by(number: "A", concept: Installment::CONCEPT[:INITIAL_PAYMENT])
  end

  def validate_concept
    required_concept = self.next_step.folder_user_concept
    required_concept.present? ? self.folder_users.where(folder_user_concept: required_concept).any? : true
  end

  def validate_client_user_concept
    valid = true
    required_client_user_concept = self.next_step.client_user_concept
    if required_client_user_concept.present?
      clients.map do |client|
        valid = client.client_users.where(client_user_concept: required_client_user_concept).any?
        break
      end
    end
    valid
  end

  def paid_down_payments_installments
    self.installments.where(concept: Installment.concepts[:down_payment]).order("number::integer DESC").select { |installment| installment if installment.is_paid? }
  end

  def paid_financing_installments
    self.installments.where(concept: Installment.concepts[:financing]).order("number::integer DESC").select { |installment| installment if installment.is_paid? }
  end

  def down_payments_installments
    self.installments.where(concept: Installment.concepts[:down_payment]).order("number::integer DESC")
  end

  def financing_installments
    self.installments.financing.order("number::integer DESC")
  end

  def quotation_total_payments
    self.installments.map { |installment| installment.payments.sum(:amount) }.inject(:+)
  end

  def purchase_conditions_formatted
    if purchase_conditions.present?
      super(
        opening_commission: payment_scheme.opening_commission,
        purchase_conditions: purchase_conditions,
        phase_date: lot.stage.phase.start_date,
        stage_date: lot.stage.release_date,
      )
    else
      lot.stage.purchase_conditions_formatted(payment_scheme.opening_commission)
    end
  end

  def is_concept_paid?(additional_concept_id)
    cash_flows.joins(:additional_concept_payments)
              .exists?(status: :active,
                      "additional_concept_payments.additional_concept_id": additional_concept_id)
  end

  def concept_payment(additional_concept_id)
    cash_flows.joins(:additional_concept_payments)
    .find_by(status: :active,
            "additional_concept_payments.additional_concept_id": additional_concept_id)
  end

  def additional_concepts_to_pay
    concepts_to_pay = []

    self.lot.stage.additional_concepts.active.each do |concept|
      concepts_to_pay << concept unless is_concept_paid?(concept.id)
    end

    concepts_to_pay
  end

  def total_amount
    installments.sum("down_payment + capital")
  end

  def digital_signature_services
    enterprise = self&.lot&.stage&.enterprise
    return [] unless enterprise.present?
    enterprise.digital_signature_services
  end

  def has_manual_signature_services?
    self.digital_signature_services.where(is_automatic: false).any?
  end

  def purchase_promise_signatures
    self.digital_signatures.where(document_type: DigitalSignature.document_types[:purchase_promise])
  end

  def completed_purchase_promise_signatures?
    completed_signatures = self.purchase_promise_signatures
    if completed_signatures.any?
      last_record = completed_signatures.order(:id).last
      last_record.finalized?
    else
      false
    end
  end

  def has_pending_purchase_promise_signatures?
    has_pending = false
    statuses = DigitalSignature.statuses
    purchase_promise_signatures = self.purchase_promise_signatures.where(status: [statuses[:initialized], statuses[:sent_to_clients_signature], statuses[:sent_for_signature_of_legal_representatives]]).order(date: :asc)
    if purchase_promise_signatures.any?
      has_pending = true
    end
    has_pending
  end

  def last_digital_signature_label
    last_d_s = get_last_digital_signature
    if last_d_s.present?
      { signature_label: last_d_s.signature_label, error: last_d_s.status == last_d_s.class.statuses[:failed], error_description: last_d_s.error_description }
    else
      { signature_label: "Sin contrato a firma", error: false }
    end
  end

  def get_last_digital_signature
    statuses = DigitalSignature.statuses
    active_statuses = [statuses[:initialized], statuses[:sent_to_clients_signature], statuses[:sent_for_signature_of_legal_representatives]]

    active_digital_signatures = digital_signatures.where(status: active_statuses).order(date: :asc)
    return active_digital_signatures.last  if active_digital_signatures.any?

    non_active_digital_signatures = digital_signatures.where.not(status: active_statuses).order(date: :asc)
    return non_active_digital_signatures.last  if non_active_digital_signatures.any?
    false
  end

  def times_in_step
    self.step_logs.where(step: self.step).count
  end

  def project
    self.lot.stage.phase.project
  end

  def phase
    self.lot.stage.phase
  end

  def stage
    self.lot.stage
  end

  def is_irregular?
    down_payment = payment_scheme.initial_payment + payment_scheme.down_payment

    (down_payment / payment_scheme.total_calculation.total) < 0.1
  end

  def commission_duration
    return payment_scheme.max_commission_amount if is_irregular?
    payment_scheme.down_payment_finance
  end

  def stp_clabe
    clabe = lot.stp_clabe(id)
    clabe.present? ? clabe : "No disponible"
  end

  def has_no_custom_payments?
    installments_with_payments(false).any?
  end

  def has_custom_payments?
    installments_with_payments(true).any?
  end

  def has_custom_installments?
    installments.custom.any?
  end

  def use_email_confirmation?
    dss = digital_signature_services.first
    return false unless dss.present?
    dss.use_email_confirmation
  end

  def confirmed_client_email?
    return true unless use_email_confirmation?
    return false unless client.confirmed_email
    return false if !client_2&.confirmed_email && client_2.present?
    return false if !client_3&.confirmed_email && client_3.present?
    return false if !client_4&.confirmed_email && client_4.present?
    return false if !client_5&.confirmed_email && client_5.present?
    return false if !client_6&.confirmed_email && client_6.present?
    true
  end

  def total_amount_overdue
    now = Time.zone.now
    amount_overdue = 0
    installments.each do |installment|
      penalty_amount = 0
      total_paid = installment.total_paid
      penalty = installment.penalty
      has_penalty = penalty.present? && penalty_amount.present? && penalty.active
      penalty_amount = penalty&.amount if has_penalty

      total_amount = installment.total + penalty_amount
      is_paid =  total_paid >= total_amount
      residue = is_paid ? 0 : total_amount - total_paid
      overdue = installment.date < now && residue > 0
      amount_overdue += total_amount - total_paid if !is_paid && overdue
    end
    amount_overdue
  end

  def concepts_message
    concepts_array = []
    unless validate_concept
      concepts_array << next_step.folder_user_concept.name
    end

    unless validate_client_user_concept
      concepts_array << next_step.client_user_concept.name
    end
    concepts_array.join(", ")
  end

  def show_interest
    !credit_scheme.simple_interest?
  end

  def remove_coupon
    coupon = self.payment_scheme.coupon
    coupon.update(usages: coupon.usages - 1) if coupon.present?
  end

  def has_down_payment_overdue
    overdue = false
    down_payments_installments.each do |installment|
      if installment.is_overdue
        overdue = true
        break
      end
    end
    overdue
  end

  def has_differed_downpayments
    payment_scheme.down_payment_finance > 1 ? true : false
  end

  def persisted_installments
    initial_payment = installments.where(concept: :initial_payment)
    down_payment_and_financing = installments.where.not(concept: :initial_payment).order("
      CASE concept
      WHEN 'down_payment' THEN 0
      WHEN 'financing' THEN 1
      ELSE 2 END").order("number::integer ASC")
    initial_payment | down_payment_and_financing
  end

  def pending_payments
    processed_installments.keep_if { |installment| !installment.is_paid? }
  end

  private

    def schedule_expirations
      initial_payment_expiration = stage.initial_payment_expiration.present? ? stage.initial_payment_expiration : 72 # hours alias to 3 days
      initial_payment_expiration += initial_payment_sudden_death if initial_payment_sudden_death.present?

      total_down_payment_expiration = stage.down_payment_expiration.present? ? stage.down_payment_expiration : 240 # hours alias to 10 days
      total_down_payment_expiration += down_payment_sudden_death if down_payment_sudden_death.present?

      if self.payment_scheme.complement_payment > 0
        FolderExpirationsJob.set(wait: initial_payment_expiration.hours).perform_later(self.id, ["initial_payment", "initial_payment_complement"])
      else
        FolderExpirationsJob.set(wait: initial_payment_expiration.hours).perform_later(self.id, ["initial_payment"])
      end

      FolderExpirationsJob.set(wait: total_down_payment_expiration.hours).perform_later(self.id, ["down_payment"])
    end

    def check_if_step_blocked
      if step_id_change.first.present? && step_id_change.second.present?
        old_step = Step.find(step_id_change.first)
        new_step = Step.find(step_id_change.second)
        return if old_step.order > new_step.order
      end

      errors.add(:step_id, "blocked") if step.present? && step.blocked?
    end

    def save_approved_date
      self.update_columns(approved_date: Time.zone.now) if approved_date.nil?
    end

    def is_folder_approved?
      step_id_previously_changed? && step == Step.last_step
    end

    def save_approved_date?
      approval_step_id = Setting.find_by(key: "approval_step_id").try(:convert)
      approval_step = Step.find_by_id(approval_step_id) || Step.last_step

      approved_date.nil? && step_id_previously_changed? && step == approval_step
    end

    def folder_owner_updated?
      user_id_previously_changed?
    end

    def update_folder_owners
      folder_users.where(concept: ["referred", "sale", "follow_up", "marketing"]).destroy_all
      set_folder_users
    end

    def deal_not_created
      deal.blank?
    end

    def delete_installments_without_payments
      # TODO: move payment validation to query and destroy with SQL
      installments.update_all(deleted_at: Time.zone.now)
    end

    def step_logger
      return if !step_id_previously_changed? && !status_previously_changed?
      if step.present?
        StepLog.create!(step: step, folder: self, user: Current.user, moved_at: Time.zone.now, status: self.status, action: self.action)
      else
        StepLog.create!(folder: self, user: Current.user, moved_at: Time.zone.now, status: self.status, action: self.action)
      end
    end

    def set_lot_status
      return if !step_id_previously_changed? && !status_previously_changed?
      LotStatusJob.perform_later(id)
    end

    def area
      self.payment_scheme.area.presence || self.lot.area
    end

    def installments_with_payments(only_custom = false)
      Payment.joins(:installment).where(status: :active, installments: { folder_id: self.id, concept: Installment::CONCEPT[:FINANCING], is_custom: only_custom, deleted_at: nil })
    end

    def liquid_format
      purchase_conditions.present? ? purchase_conditions_formatted : nil
    rescue Liquid::SyntaxError
      errors.add(:purchase_conditions, :liquid_error)
    end

    def get_document(template_name)
      digital_signature_service = digital_signature_services.first
      return nil unless digital_signature_service.present?
      template_id = digital_signature_service.public_send(template_name.to_sym)
      return nil unless template_id.present?
      document = documents.find_by(document_template_id: template_id)
      return nil unless document.present?
      latest_file_version = document.latest_file_version
      return nil unless latest_file_version.present?
      latest_file_version.file.download
    end
end
