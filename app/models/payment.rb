# frozen_string_literal: true

class Payment < ApplicationRecord
  include CommissionsHelper, PaymentPayActionsConcern
  acts_as_paranoid

  STATUS = { ACTIVE: "active", CANCELED: "canceled" }
  enum status: { active: "active", canceled: "canceled" }

  scope :without_restructures, -> (folder_id, number) { joins(:installment).left_joins(:restructure)
    .where(restructures: { id: nil }, status: :active, installments: { folder_id: folder_id, number: number, concept: :financing }) }

  belongs_to :installment
  belongs_to :client
  belongs_to :user, required: false
  belongs_to :branch, required: false
  belongs_to :cash_flow, required: false
  belongs_to :canceled_by, class_name: "User", foreign_key: "canceled_by", required: false
  has_one :restructure

  has_many :commissions

  accepts_nested_attributes_for :cash_flow
  accepts_nested_attributes_for :restructure

  before_create :set_defaults
  after_create :send_email, if: :non_money_restructure?
  after_update :cancel_restructure

  def self.search(params:, hide_restructures: true)
    payments = Payment.includes([installment: [folder: [:client, :payment_scheme, lot: [stage: [phase: :project]], user: [:branch, :structure]]]])
    payments = payments.where.not(amount: 0) if hide_restructures
    payments = payments.where(client_id: Client.where("LOWER(CONCAT(name, first_surname, second_surname)) LIKE LOWER(?)", "%#{params[:name].tr(" ", "%")}%".delete(" \t\r\n"))) if params[:name].present?
    payments = payments.where(client_id: Client.where("LOWER(email) LIKE LOWER(?)", "%#{params[:email]}%".delete(" \t\r\n"))) if params[:email].present?
    payments = payments.where("lots.number" => params[:lot_number].delete(" \t\r\n")) if params[:lot_number].present?
    payments = payments.where("LOWER(lots.label) = LOWER(?)", params[:lot_label]) if params[:lot_label].present?
    payments = payments.where(status: params[:status]) if params[:status].present?
    payments = payments.where("projects.id" => params[:project]) if params[:project].present?
    payments = payments.where("phases.id" => params[:phase]) if params[:phase].present?
    payments = payments.where("stages.id" => params[:stage]) if params[:stage].present?
    payments = payments.where("folders.id" => params[:folio]) if params[:folio].present?
    payments = payments.where(user_id: User.where("LOWER(CONCAT(first_name, last_name)) LIKE LOWER(?)", "%#{params[:salesman].tr(" ", "%")}%")) if params[:salesman].present?
    payments = payments.where("payments.created_at BETWEEN ? and ?", params[:from_date].to_time.strftime("%Y-%m-%d 00:00:00"), params[:to_date].to_time.strftime("%Y-%m-%d 23:59:59")) if params[:from_date].present? && params[:to_date].present?
    payments
  end

  def set_defaults
    self.status = Payment::STATUS[:ACTIVE]
  end

  def status_label
    statuses = {
        STATUS[:ACTIVE] => "Activo",
        STATUS[:CANCELED] => "Cancelado",
    }
    statuses[self.status]
  end

  def can_be_canceled?
    self.restructure.nil? || self.restructure.present? && self.installment.folder.last_active_payment == self
  end

  def is_time_restructure
    self.restructure.present? && [Restructure::CONCEPT[:FINANCING_TIME], Restructure::CONCEPT[:DOWN_PAYMENT_TIME]].include?(self.restructure.concept)
  end

  def cancel_restructure
    self.restructure.update_installments if self.restructure.present?
  end

  def to_file(for_email = true, voucher = false, with_signature = false)
    if non_money_restructure?
      name = voucher ? "RECIBO DE REESTRUCTURA" : "COMPROBANTE DE REESTRUCTURA"
      PaymentInvoice.new(self, { for_email: for_email, name: name, with_signature: with_signature })
    else
      cash_flow.to_file(for_email, voucher, with_signature)
    end
  end

  def send_email(resend: false)
    if installment.folder.active_mails || resend
      if non_money_restructure?
        PaymentMailer.notify_new_payment(self).deliver_later
      else
        cash_flow.send_email(resend: resend)
      end
    end
  end

  def percentage_paid
    (self.amount / self.installment.total * 100).round(2)
  end

  private
    def non_money_restructure?
      restructure.present? && amount.zero?
    end
end
