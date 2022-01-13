# frozen_string_literal: true

class Commission < ApplicationRecord
  include QuotationsHelper

  STATUS = { PAID: "paid", PENDING: "pending", CANCELED: "canceled" }

  enum status: HashWithIndifferentAccess.new(paid: STATUS[:PAID], pending: STATUS[:PENDING], canceled: STATUS[:CANCELED])

  scope :not_canceled, ->() { where("status != ?",  STATUS[:CANCELED]) }

  belongs_to :installment
  belongs_to :folder_user, with_deleted: true
  belongs_to :payment
  belongs_to :payment_method, required: false, with_deleted: true

  has_one_attached :voucher
  has_one_attached :invoice

  delegate :cash_flow, to: :payment

  after_update :binnacle

  def self.set_params(params, sort_column, sort_direction)
    order(sort_column + " " + sort_direction).search(params)
  end

  def self.search(params)
    commissions = Commission.includes(folder_user: :user, installment: { folder: { lot: { stage: { phase: :project } } } })
    commissions = commissions.where("users.id" => User.where(role_id: params[:role])) if params[:role].present?
    commissions = commissions.where(status: params[:status]) if params[:status].present?
    commissions = commissions.where("projects.id" => params[:project]) if params[:project].present?
    commissions = commissions.where("phases.id" =>  params[:phase]) if  params[:phase].present?
    commissions = commissions.where("stages.id" => params[:stage]) if params[:stage].present?
    commissions = commissions.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
    commissions = commissions.where("LOWER(lots.label) = LOWER(?)", params[:lot_label]) if params[:lot_label].present?
    commissions = commissions.where("users.id" => User.where("LOWER(email) LIKE LOWER(?)", "%#{params[:user_email]}%".delete(" \t\r\n"))) if params[:user_email].present?
    commissions = commissions.where("users.id" => User.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:user_name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:user_name].present?
    commissions = commissions.where("folder_users.folder_user_concept_id" => params[:concept]) if params[:concept].present?
    commissions = commissions.where("folders.id" => params[:folder]) if params[:folder].present?
    commissions = commissions.where("commissions.date BETWEEN ? AND ?", params[:from_date].to_datetime, params[:to_date].to_datetime.end_of_day) if params[:from_date].present? && params[:to_date].present?
    commissions
  end

  def self.status_key(value)
    statuses = {
        "Pagado" => STATUS[:PAID],
        "Pendiente" => STATUS[:PENDING],
        "Cancelado" => STATUS[:CANCELED]
    }
    statuses[value]
  end

  def amount_paid
    amount = 0

    Commission.paid.where(folder_user: folder_user).each do |comm|
      amount += comm.amount
    end

    amount
  end

  def amount_pending
    amount - amount_paid
  end

  def sale_total
    (folder_user.amount * 100) / (folder_user.percentage).to_f
  end

  def is_irregular
    payment_scheme = installment.folder.payment_scheme

    down_payment = payment_scheme.initial_payment + payment_scheme.down_payment
    total = ApplicationController.helpers.get_total_amount(self)

    (down_payment / total) < 0.1
  end

  def get_numeration
    folder = installment.folder
    current = folder_user.commissions.order(date: :asc).find_index(self) + 1

    if is_irregular
      total = folder.payment_scheme.max_commission_amount + 1
    else
      total = folder.payment_scheme.down_payment_finance + 1
    end

    "#{current.to_i}/#{total}"
  end

  def status_translated
    I18n.t("activerecord.attributes.commissions.statuses.#{status}")
  end

  def status_label
    statuses = {
        STATUS[:PAID] => "Pagado",
        STATUS[:PENDING] => "Pendiente",
        STATUS[:CANCELED] => "Cancelado"
    }
    statuses[self.status]
  end

  private

    def binnacle
      unless Current.user.nil?
        filtered_changes = previous_changes
        previous_changes.keys.each do |attr_name, attr_value|
          if previous_changes[attr_name][0].nil?
            filtered_changes = filtered_changes.except(attr_name)
          end
        end
        element_changes = "#{filtered_changes.except(:updated_at)}".gsub("=>", ":")

        if element_changes != "{}"
          @log = {
              date: Time.zone.now,
              element_changes: element_changes,
              element: "commission",
              element_id: self.id,
              user_id: Current.user.id
          }

          Log.create(@log)
        end
      end
    end
end
