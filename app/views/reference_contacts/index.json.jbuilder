# frozen_string_literal: true

json.array! @reference_contacts do |reference_contact|
  json.id reference_contact.id
  json.client_id reference_contact.client_id
  json.contact_name reference_contact.name
  json.contact_email reference_contact.email
  json.contact_concept reference_contact.concept
  json.contact_phone reference_contact.phone
end
