# frozen_string_literal: true

json.id attachment.id
json.name attachment.name
json.record_type attachment.record_type
json.record_id attachment.record_id

json.file do
  json.id attachment.blob.id
  json.key attachment.blob.key
  json.filename attachment.blob.filename
  json.content_type attachment.blob.content_type
  json.file_url Rails.application.routes.url_helpers.rails_blob_url(attachment.blob)
end
