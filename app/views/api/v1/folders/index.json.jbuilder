# frozen_string_literal: true

json.array! @folders do |folder|
  json.id folder.id
  json.adviser_name folder.user.label
  json.client folder.client.label
  json.project_name folder.project.name
  json.phase folder.phase.name
  json.stage folder.stage.name
  json.lot folder.lot.name
  json.calc_date folder.calc_date.strftime("%F")
  if folder.payment_scheme.present?
    payment_scheme = folder.payment_scheme
    json.payment_scheme do
      json.id payment_scheme.id
      json.name payment_scheme.name
      json.initial_payment text_to_decimal(payment_scheme.initial_payment, 6)
      json.discount text_to_decimal(payment_scheme.discount, 6)
      json.total_payments payment_scheme.total_payments
      json.dfp payment_scheme.dfp
      json.down_payment_finance payment_scheme.down_payment_finance == 1 ? "Contado" : "Diferido"
      json.down_payment text_to_decimal(payment_scheme.down_payment, 6)
      json.buy_price text_to_decimal(payment_scheme.buy_price, 6)
      json.zero_rate payment_scheme.zero_rate
      json.down_payment_paid (payment_scheme.down_payment_paid ? "Pagado" : "No pagado")
      json.first_payment payment_scheme.first_payment
      json.promotion text_to_decimal(payment_scheme.promotion, 6)
      json.promotion_name payment_scheme.promotion_name
      json.promotion_operation payment_scheme.operation_label
      json.lock_payment text_to_decimal(payment_scheme.lock_payment, 6)
      json.credit_scheme payment_scheme.credit_scheme.name
      json.immediate_extra_months payment_scheme.immediate_extra_months
      json.opening_commission text_to_decimal(payment_scheme.opening_commission, 6)
    end
  end
end
