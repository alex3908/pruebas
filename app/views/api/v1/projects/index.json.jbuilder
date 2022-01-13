# frozen_string_literal: true

json.array! @projects.api_format do |project|
  json.id project.id
  json.name project.name
  json.email project.email
  json.phone project.phone
  json.quotation project.quotation
  json.logo project.logo_attached_path
end
