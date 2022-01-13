# frozen_string_literal: true

json.array! @phases.api_format do |phase|
  json.id phase.id
  json.name phase.name
  json.start_date phase.start_date
end
