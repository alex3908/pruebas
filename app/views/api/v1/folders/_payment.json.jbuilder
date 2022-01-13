# frozen_string_literal: true


json.number payment[:number]
json.date payment[:date].strftime("%d/%m/%Y")
json.capital text_to_decimal(payment[:capital], 6)
json.interest text_to_decimal(payment[:interest], 6)
if @folder_quotation.is_down_payment_differ
  json.down_payment text_to_decimal(payment[:down_payment], 6)
end
json.payment text_to_decimal(payment[:payment], 6)
json.residue text_to_decimal((payment[:residue].present? ? payment[:residue] : payment[:payment]), 6)
json.amount text_to_decimal(payment[:amount], 6)
