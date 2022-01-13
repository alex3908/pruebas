# frozen_string_literal: true

class FolderUser < ApplicationRecord
  include Filterable, PaymentProcessorConcern
  acts_as_paranoid

  CONCEPT = { REFERRED: "referred", SALE: "sale", FOLLOW_UP: "follow_up", MARKETING: "marketing", EXTRA: "extra" }
  enum concept: { referred: "referred", sale: "sale", follow_up: "follow_up", marketing: "marketing", extra: "extra" }

  scope :visible, ->() { where(visible: true) }

  belongs_to :user
  belongs_to :folder
  belongs_to :role
  belongs_to :folder_user_concept
  has_many :commissions

  after_create :set_percentage
  after_create :set_amount
  after_create :binnacle
  after_update :binnacle
  after_update :generate_pending_commissions
  after_destroy :binnacle
  after_destroy :cancel_pending_commissions

  def self.set_params(params, sort_column, sort_direction)
    includes(:user, :role, :folder_user_concept, folder: { lot: { stage: { phase: :project } } }).order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    folder_users = joins(:user, :role, :folder_user_concept, folder: { lot: { stage: { phase: :project } } })
    folder_users = folder_users.where("users.id" => User.where(role_id: params[:role])) if params[:role].present?
    folder_users = folder_users.where("projects.id" => params[:project]) if params[:project].present?
    folder_users = folder_users.where("phases.id" =>  params[:phase]) if  params[:phase].present?
    folder_users = folder_users.where("stages.id" => params[:stage]) if params[:stage].present?
    folder_users = folder_users.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
    folder_users = folder_users.where("LOWER(lots.label) = LOWER(?)", params[:lot_label]) if params[:lot_label].present?
    folder_users = folder_users.where("users.id" => User.where("LOWER(email) LIKE LOWER(?)", "%#{params[:user_email]}%".delete(" \t\r\n"))) if params[:user_email].present?
    folder_users = folder_users.where("users.id" => User.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:user_name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:user_name].present?
    folder_users = folder_users.where("folder_users.folder_user_concept_id" => params[:concept]) if params[:concept].present?
    folder_users = folder_users.where("folders.id" => params[:folder]) if params[:folder].present?
    folder_users
  end

  def set_percentage
    return if percentage.present?

    self.update(percentage: self.folder_user_concept.commission)
  end

  def binnacle
    filtered_changes = previous_changes
    previous_changes.keys.each do |attr_name, attr_value|
      if previous_changes[attr_name][0].nil?
        filtered_changes[attr_name][0] = ""
      end

      if previous_changes[attr_name][1].nil?
        filtered_changes[attr_name][1] = ""
      end
    end

    if self.deleted_at.present?
      deleted_at_log = { deleted_at: ["", self.deleted_at.strftime("%d/%m/%Y %I:%M%p")] }
      filtered_changes = filtered_changes.merge(deleted_at_log)
    end

    element_changes = "#{filtered_changes.except(:created_at, :updated_at)}".gsub("=>", ":")

    if element_changes != "{}"
      Log.create({ date: Time.zone.now,
                  element_changes: element_changes,
                  element: "folder_user",
                  element_id: self.id,
                  user_id: Current.user&.id }
      )
    end
  end

  def cancel_pending_commissions
    commissions.pending.each do |commission|
      commission.canceled!
    end
  end

  def generate_pending_commissions
    return unless percentage_previously_changed?

    cancel_pending_commissions
    @quotation = folder.generate_quote
    amount = @quotation.total_with_discount * (percentage / 100)
    update_column("amount", amount)
    folder.installments.each do |installment|
      next unless installment.is_paid? && installment.payments.any?
      next if installment.commissions.not_canceled.size > 0
      create_commissions(installment.down_payment, installment.payments.last)
    end
  end

  def set_amount
    return unless folder.finished?
    @quotation = folder.generate_quote
    amount = @quotation.total_with_discount * (percentage / 100)
    update_column("amount", amount)
  end
end
