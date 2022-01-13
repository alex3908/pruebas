# frozen_string_literal: true

json.can_send_signature_link_by_whatsapp @step_role&.can_send_signature_link_by_whatsapp?
json.can_send_signature_link_by_email @step_role&.can_send_signature_link_by_email?
json.can_send_signature_link_by_clipboard @step_role&.can_send_signature_link_by_clipboard?
json.linkItems do
  json.array! @participants do |participant|
    json.id participant.id
    json.sign_url participant.sign_url
    json.email participant.email
    json.name participant.name
    json.phone participant.phone
  end
end
