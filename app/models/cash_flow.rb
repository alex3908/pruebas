# frozen_string_literal: true

class CashFlow < ApplicationRecord
  STATUS = { ACTIVE: "active", CANCELED: "canceled" }
  enum status: { active: "active", canceled: "canceled" }

  scope :cash_back, -> { active.where(cash_back: true) }

  belongs_to :folder
  belongs_to :client
  belongs_to :payment_method, required: false, with_deleted: true
  belongs_to :branch, required: false
  belongs_to :user, required: false
  belongs_to :bank_account, required: false
  belongs_to :canceled_by, class_name: "User", foreign_key: "canceled_by", required: false
  has_many :payments, dependent: :delete_all
  has_many :cash_back_flows
  has_many :additional_concept_payments, dependent: :delete_all

  accepts_nested_attributes_for :payments
  accepts_nested_attributes_for :additional_concept_payments

  has_one_attached :voucher

  before_create :set_defaults
  after_update :cancel_commissions, if: :was_canceled?
  after_create :send_email

  def set_defaults
    self.status = CashFlow::STATUS[:ACTIVE]
  end

  def status_label
    statuses = {
        STATUS[:ACTIVE] => "Activo",
        STATUS[:CANCELED] => "Cancelado",
    }
    statuses[self.status]
  end

  def payment_method_label
    return self.payment_method.name if self.payment_method.present?
    return "Pago en línea" if self.charge_id.present?
    "N/A"
  end

  def bank_account_label
    return self.bank_account.bank if self.bank_account.present?
    "N/A"
  end

  def bank_account_clabe
    self.bank_account.clabe if self.bank_account.present?
  end

  def first_payment
    self.payments.first
  end

  def first_concept_payment
    self.additional_concept_payments.first
  end

  def folio
    "#{self.folder.lot.reference}-#{self.id}"
  end

  def can_be_canceled?
    return true if self.first_concept_payment.present? && self.active?
    self.first_payment.present? && (self.first_payment.restructure.nil? || self.first_payment.restructure.present? && self.folder.last_active_payment == self.first_payment)
  end

  def concept
    concept = Hash.new
    if self.payments.size > 0
      Installment.concepts.keys.each do |installment_concept|
        concept[:"#{installment_concept}"] = []
      end
      concept[:restructure] = []
      self.payments.each do |payment|
        if payment.restructure.present?
          concept[:restructure] << { restructure_concept: "#{payment.restructure.concept_label}" }
        elsif payment.installment.concept == Installment::CONCEPT[:INITIAL_PAYMENT]
          concept[:initial_payment] << { currency: payment.amount, percentage: payment.percentage_paid }
        elsif payment.installment.concept == Installment::CONCEPT[:DOWN_PAYMENT]
          concept[:down_payment] << { currency: payment.amount, percentage: payment.percentage_paid }
        else
          concept[:financing] << { number: payment.installment.number, currency: payment.amount, percentage: payment.percentage_paid }
        end

        if payment.installment.concept == Installment::CONCEPT[:FINANCING] && payment.installment.down_payment > 0
          term = payment.installment.number.to_i + (self.folder.payment_scheme.start_installments || 0)
          concept[:down_payment] << { term: term }
        end
      end

    end

    if self.additional_concept_payments.size > 0
      concept[:additional_concept] = []
      self.additional_concept_payments.each do |concept_payment|
        concept[:additional_concept] << { concept_name: "#{concept_payment.additional_concept_name}" }
      end
    end
    concept
  end

  def to_file(for_email = true, voucher = false, with_signature = false)
    name = voucher ? "RECIBO DE PAGO" : "COMPROBANTE DE PAGO"
    CashFlowInvoice.new(self, { for_email: for_email, name: name, with_signature: with_signature })
  end

  def send_email(resend: false)
    if folder.invoice_enabled || resend
      PaymentMailer.notify_new_cashflow(self).deliver_later
    end
  end

  private
    def cancel_commissions
      payments.includes(:commissions).each do |payment|
        payment.commissions
          .where(status: Commission::STATUS[:PENDING])
          .update_all(status: Commission::STATUS[:CANCELED])
      end
    end

    def was_canceled?
      %i[canceled_by cancellation_date].all? { |k| previous_changes.key? k }
    end
end
