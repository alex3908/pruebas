# frozen_string_literal: true

json.extract! identification_type, :id, :name, :institution, :created_at, :updated_at
json.url identification_type_url(identification_type, format: :json)
