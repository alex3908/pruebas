# frozen_string_literal: true

class PreviewEmailTemplate < PurchasePromise
  include PreviewConcern

  def initialize(email_template)
    @template = email_template.template

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
    @contract = Contract.new

    super(@folder)
  end

  def get_html
    locals[:code_block]
  end
end
