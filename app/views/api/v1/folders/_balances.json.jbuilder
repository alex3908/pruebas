# frozen_string_literal: true

json.folder_id balance[:folder].id
json.approved_date balance[:folder]&.approved_date&.strftime("%d/%m/%Y")
json.client_name balance[:folder].client.label
json.project_name balance[:folder].lot.stage.phase.project.name
json.phase_name balance[:folder].lot.stage.phase.name
json.stage_name balance[:folder].lot.stage.name
json.lot_name balance[:folder].lot.name
json.lot_area text_to_decimal(balance[:folder].lot.area, 6)
json.total_with_discount text_to_decimal(balance[:overdue_payments][:total_with_discount], 6)
json.count_of_installments_paid balance[:overdue_payments][:count_of_installments_paid]
json.date_of_the_last_paid balance[:overdue_payments][:date_of_the_last_paid]
json.amount_paid text_to_decimal(balance[:overdue_payments][:amount_paid], 6)
json.count_of_overdue_payments balance[:overdue_payments][:count_of_overdue_payments]
json.overdue_amount text_to_decimal(balance[:overdue_payments][:overdue_amount], 6)

if balance[:is_evo] && balance[:folder].user.structure.present?
  evo_structure = Role.evo_structure
  staff_structure = balance[:folder].user.structure.staff_structure(evo_structure)
  evo_structure.each do |evo_level|
    json.set! evo_level.key, staff_structure[evo_level.key]&.user&.label
  end
else
  json.user_label balance[:folder].user.label
end
