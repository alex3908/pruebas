# frozen_string_literal: true

class ContractRules
  attr_accessor :client_gender, :lot_type, :client_type, :client_nationality, :periods_amount, :financing_type, :differed_downpayment, :clients, :area, :total

  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end
end
