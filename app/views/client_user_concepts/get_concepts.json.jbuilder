# frozen_string_literal: true

json.client_user_concepts do
  json.array! @client_user_concepts do |client_user_concept|
    json.id client_user_concept.id
    json.text client_user_concept.name
  end
end
