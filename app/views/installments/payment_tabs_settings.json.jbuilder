# frozen_string_literal: true

json.actual_date Time.zone.now.strftime("%d/%m/%Y")
json.disabled @disabled
json.user @folder.user.label
json.payment_method @payment_method.present? ? @payment_method.id : ""
json.bank_account @bank_account.present? ? @bank_account.id : ""
json.branch @branch.present? ? @branch.id : ""
json.show_amount @show_amount
json.set_date can?(:set_date, Installment)
json.total_residue @total_residue
json.is_down_payment @next_installment.present? ? @next_installment[:is_down_payment] : false
json.next_installment_number @next_installment.present? ? @next_installment[:number] : 0
json.amount_overdue @amount_overdue
json.is_down_payment_differ @is_down_payment_differ
json.can_create_or_update_penalty can?(:create, Penalty) || can?(:update, Penalty)
json.cannot_add_capital_payments @cannot_add_capital_payments
json.restructure_message @restructure_message
json.has_active_suscriptions @folder.subscriptions.currently_active.present?
json.capital_payment_concepts @capital_payment_concepts
json.min_capital_payment @stage.credit_scheme.min_capital_payment
json.total_payments @total_payments
json.minimum_term @minimum_term
json.maximum_term @maximum_term
json.max_delay_payments @stage.credit_scheme.max_delay_payments
json.concept @next_installment.present? ? @next_installment[:concept] : ""
json.next @next_installment.present? ? @next_installment[:number] : 0
json.next_date @next_installment.present? ? @next_installment[:date].to_date.strftime("%d/%m/%Y") : Time.zone.now.strftime("%d/%m/%Y")
json.next_down_payment  @next_down_payment.present? ? @next_down_payment : 0
json.down_payment_count @down_payment_count
json.can_show_form @can_show_form

json.client do
  json.id @client.id
  json.label @client.label
end
json.clients do
  json.array! @clients do |client|
    json.id client.id
    json.name client.label
  end
end

json.payment_methods do
  json.array! @payment_methods do |payment_method|
    json.id payment_method.id
    json.name payment_method.name
  end
end

json.bank_accounts do
  json.array! @stage.enterprise.bank_accounts do |bank_account|
    json.id bank_account.id
    json.name "#{bank_account.bank} - #{bank_account.account_number}"
  end
end

json.branches do
  json.array! @branches do |branch|
    json.id branch.id
    json.name branch.name
  end
end

json.delay_concepts do
  json.array! Restructure.delay_concept do |delay_concept|
    json.delay_type delay_concept[1]
    json.label delay_concept[0]
  end
end

json.additional_concept_options do
  json.array! @additional_concept_options
end
