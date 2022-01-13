# frozen_string_literal: true

json.phase do
  json.id @phase.id
  json.name @phase.name
  json.blueprint_url ActionController::Base.asset_host + "/disponibilidad.svg?fase=#{Base64.strict_encode64(@phase.id.to_s)}"
end
json.stage do
  json.id @stage.id
  json.name @stage.name
  json.blueprint_url ActionController::Base.asset_host + "/disponibilidad.svg?etapa=#{Base64.strict_encode64(@stage.id.to_s)}"
end
