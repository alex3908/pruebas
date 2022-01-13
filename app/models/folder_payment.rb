# frozen_string_literal: true

class FolderPayment
  attr_reader :folder, :quotation, :all_installments, :cash_flows, :payments
  def initialize(folder, quotation, all_installments, cash_flows, payments)
    @folder = folder
    @quotation = quotation
    @all_installments = all_installments
    @cash_flows = cash_flows
    @payments = payments
  end
end
