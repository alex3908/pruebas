# frozen_string_literal: true

json.set! :installments, @custom_installments
json.installments @custom_installments do |installment|
  json.id installment.id
  json.capital installment.capital
  json.date installment.date
  json.debt installment.debt
  json.interest installment.interest
  json.number installment.number
  json.total installment.total
  json.valid_date true
  json.valid_capital true
end

json.set! :is_payments_limit, @is_payments_limit
json.set! :capital_residue, @capital_residue
json.set! :add_item, @add_item
json.set! :has_no_custom_payments, @has_no_custom_payments
json.set! :has_custom_payments, @has_custom_payments
json.set! :totalSale, @total_sale
