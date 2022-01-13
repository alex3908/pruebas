# frozen_string_literal: true

class ClientsApi::V1::AddressSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :country, :postal_code, :state, :city, :colony, :location, :street
end
