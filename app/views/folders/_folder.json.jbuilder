# frozen_string_literal: true

json.extract! folder, :id, :created_at, :updated_at

json.link_url folder_path(folder)
json.url folder_path(folder, format: :json)

json.project do
  json.name folder.project.name
  json.entity_name folder.lot.project.project_entity_name
end

json.phase do
  json.name folder.phase.name
  json.entity_name folder.lot.project.phase_entity_name
end

json.stage do
  json.name folder.stage.name
  json.show_full_name folder.stage.show_full_name
  json.entity_name folder.lot.project.stage_entity_name
end

json.lot do
  json.name folder.lot.name
  json.entity_name folder.lot.project.lot_entity_name
end

json.client folder.client.label

json.role_view @role_view

if @role_view == :director
  key = "vice_director"
elsif @role_view == :vice_director
  key = "manager"
elsif @role_view == :manager
  key = "coordinator"
elsif @role_view == :coordinator
  key = "salesman"
end
if key.present?
  json.folder_users do
    json.array! folder.folder_users.filter { |fu| fu.user.role.key == key } do |folder_user|
      json.name folder_user.user.label
      json.avatar_url image_url(folder_user.user.image_nil)
    end
  end
else
  json.folder_users [{
    name: folder.user.label,
    avatar_url: image_url(folder.user.image_nil)
  }]
end

json.operation_time operation_time(folder)
if folder.step.present? && folder.step_logs.present?
  json.time_in_step time_in_step(folder, true)
end
json.required_documents_progress folder.required_documents_progress
json.total_sale number_to_currency(folder.total_sale)
json.back_to_step folder.times_in_step - 1
json.avatar_url url_for(folder.user.avatar) if folder.user.avatar.attached?
json.responsable_name folder.user.label
