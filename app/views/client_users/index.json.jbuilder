# frozen_string_literal: true

json.client_users do
  json.array! @client_users  do |client_user|
    json.client_user_id client_user.id
    json.user_id client_user.user.id
    json.user_name client_user.user.label
    json.user_email client_user.user.email
    json.user_phone client_user.user.phone.blank? ? "Sin número registrado" : client_user.user.phone
    json.concept_id client_user.client_user_concept.id
    json.concept client_user.client_user_concept.name
  end
end
