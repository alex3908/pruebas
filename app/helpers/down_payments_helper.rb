# frozen_string_literal: true

module DownPaymentsHelper
  def get_min_down_payment(total_payments, lot)
    down_payment = DownPayment.where("term <= (?) AND credit_scheme_id = (?)", total_payments, lot.stage.credit_scheme_id).order(term: :desc).first
    down_payment.min
  end
end
