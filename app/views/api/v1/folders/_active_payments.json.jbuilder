# frozen_string_literal: true

@folder_quotation = folder_payment.quotation
json.folder_id folder_payment.folder.id
json.active_payments do
  json.partial! "api/v1/folders/payment", collection: folder_payment.all_installments.select { |installment| (installment[:paid] == true && installment[:amount].present?) }, as: :payment
end
next_payment = folder_payment.all_installments.select { |installment| (installment[:is_next_payment] == true) }.first
if next_payment.present?
  json.nex_payment do
    json.partial! "api/v1/folders/payment", payment: next_payment
  end
end

json.cash_flows do
  json.array! folder_payment.cash_flows.includes(:client, :branch, :payment_method, payments: [:installment, :restructure]) do |cash_flow|
    json.id cash_flow.id
    json.client_id cash_flow.client.id
    json.client_name cash_flow.client.label
    json.branch_id cash_flow.branch.id
    json.branch_name cash_flow.branch.name
    json.user_id cash_flow.user.id
    json.user_name cash_flow.user.label
    json.payment_method_id cash_flow.payment_method.id
    json.payment_method_name cash_flow.payment_method.name

    if cash_flow.bank_account.present?
      json.bank_account_id cash_flow.bank_account.id
      json.bank_account_name cash_flow.bank_account.bank
    end

    json.date cash_flow.date
    json.amount text_to_decimal(cash_flow.amount, 6)
    json.status cash_flow.status
    json.canceled_by cash_flow.canceled_by
    json.cash_back cash_flow.cash_back
  end
end

json.restructures do
  json.array! folder_payment.payments do |payment|
    json.canceled payment.canceled?
    json.status payment.status_label
    json.created_at payment.created_at.strftime("%d/%m/%Y")
    json.installment_id payment.installment.id
    json.installment_name payment.installment.label
    json.branch_id payment.branch.id
    json.branch_name payment.branch.name
    json.client_id payment.client.id
    json.client_name payment.client.label
    json.restructure_id payment.restructure.id
    json.restructure_name payment.restructure.concept_label
    json.restructure_name payment.restructure.concept_label
    json.current_term payment.restructure.current_term
    json.current_discount text_to_decimal(payment.restructure.current_discount, 6)
    json.current_day payment.restructure.current_day
    json.grace_months payment.restructure.grace_months
  end
end
