# frozen_string_literal: true

class PurchasePromisePreview < PurchasePromise
  include PreviewConcern
  def initialize(contract)
    @template = contract.template
    @margin = true
    @contract = contract
    @quotation = generate_amortization(
      price: 300 * 2500,
      area: 300,
      start_date: Time.zone.now - 10.days,
      date: Time.zone.now - 1.month,
      total_payments: 180,
      down_payment_total_payments: 2,
      discount: 10,
      buy_price: 2500,
      initial_payment: 5000,
      down_payment: 57750,
      first_payment: 8,
      project_type: "new"
    )

    @folder = Folder.new
    @lot = Lot.new

    super(@folder, @margin)
  end
end
