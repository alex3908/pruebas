# frozen_string_literal: true

json.invalid_capital_payment @invalid_capital_payment
json.capital_payment_concepts @capital_payment_concepts
json.invalid_restructure @invalid_restructure
json.min_total_payments @min_total_payments
json.invalid_delay @invalid_delay
json.invalid_day_restructure @invalid_day_restructure
json.day_message @day_message
json.has_multiple !@multiple_restructure.nil? && @multiple_restructure[:multiple_restructure]
json.next_multiple_installment !@multiple_restructure.nil? ? @multiple_restructure[:installment] : ""
json.next_multiple_concept !@multiple_restructure.nil? ? @multiple_restructure[:concept] : ""
json.installments do
  json.array! @all_installments
end
