# frozen_string_literal: true

class CustomQuote
  attr_accessor :date, :discount, :buy_price, :first_payment, :start_installments
  attr_accessor :zero_rate, :promotion, :promotion_operation, :promotion_name
  attr_accessor :down_payment, :initial_payment, :down_payment_finance
  attr_accessor :credit_scheme, :is_commissionable

  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end
end
