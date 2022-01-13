# frozen_string_literal: true

client_profile = folder.client.get_person
financed_type = folder.payment_scheme.total_payments <= 12 ? "Contado" : "Financiamiento"
down_payment_type = folder.payment_scheme.down_payment_finance == 1 ? "Enganche de contado" : "Enganche diferido"
down_payment = folder.total_down_payment
approved_date = folder.approved_date.present? ? folder.approved_date.strftime("%F") : ""
quotation = folder.generate_quote
contract_active = folder.active? ? "ACTIVA" : "NO ACTIVA"
operation_days = folder.approved_date.nil? ? (Time.now.to_date - folder.calc_date.to_date).to_i : (folder.approved_date.to_date - folder.calc_date.to_date).to_i

json.folder_id folder.id
json.created_at folder.created_at.strftime("%F")
json.approved_date approved_date
json.operation_days operation_days
json.contract_active contract_active
json.project_name folder.project.name
json.phase_name folder.phase.name
json.stage_name folder.stage.name
json.lot_name folder.lot.name
json.lot_area text_to_decimal(folder.lot.area, 6)
json.buy_price text_to_decimal(folder.payment_scheme.buy_price, 6)
json.discount text_to_decimal(quotation.discount, 6)
json.scheme_name folder.payment_scheme.name
json.total_with_discount text_to_decimal(quotation.total_with_discount, 6)
json.client_name folder.client.label
json.client_email folder.client.email
json.client_name_2 folder.client_2&.label
json.client_email_2 folder.client_2&.email
json.client_name_3 folder.client_3&.label
json.client_email_3 folder.client_3&.email
json.client_name_4 folder.client_4&.label
json.client_email_4 folder.client_4&.email
json.client_name_5 folder.client_5&.label
json.client_email_5 folder.client_5&.email
json.client_name_6 folder.client_6&.label
json.client_email_6 folder.client_6&.email
json.status_label folder.status_label
json.branch_name folder.user.branch&.name
json.state client_profile&.state
json.financed_type financed_type
json.payment_scheme_name folder.payment_scheme.name
json.down_payment_type down_payment_type
json.down_payment text_to_decimal(down_payment, 6)
json.down_payment_finance folder.payment_scheme.down_payment_finance
json.lot_area folder.lot.area
json.branch_name folder.user.branch&.name
json.lot_reference folder.lot.reference
json.promotion_name folder.payment_scheme.promotion_name

initial_periods = quotation.initial_periods

json.first_amount text_to_decimal(quotation.initial_periods.first[:amount], 6) if initial_periods.first.present?
json.first_payments quotation.initial_periods.first[:payments] if initial_periods.first.present?
json.second_amount text_to_decimal(quotation.initial_periods.second[:amount], 6) if initial_periods.second.present?
json.second_payments quotation.initial_periods.second[:payments] if initial_periods.second.present?
json.third_amount text_to_decimal(quotation.initial_periods.third[:amount], 6) if initial_periods.third.present?
json.third_payments quotation.initial_periods.third[:payments] if initial_periods.third.present?
json.promotion_name folder.payment_scheme.promotion_name
json.scheme_promotion text_to_decimal((folder.payment_scheme.promotion * 100), 6)
json.operation_label folder.payment_scheme.operation_label

if @is_evo && folder.user.structure.present?
  evo_structure = Role.evo_structure
  staff_structure = folder.user&.structure&.staff_structure(evo_structure)
  evo_structure.each do |evo_level|
    json.set! "#{evo_level.key.downcase}_name", staff_structure[evo_level.key]&.user&.label
    json.set! "#{evo_level.key.downcase}_email", staff_structure[evo_level.key]&.user&.email
  end
else
  json.user_name folder.user.label
  json.user_email folder.user.email
end
