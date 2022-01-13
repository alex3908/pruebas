# frozen_string_literal: true

json.array! @stages do |stage|
  json.id stage.id
  json.name stage.name
  json.enterprise do
    json.id stage.enterprise.id
    json.business_name stage.enterprise.business_name
  end
end
