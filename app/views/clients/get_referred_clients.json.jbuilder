# frozen_string_literal: true

json.referred_clients do
  json.array! @client.referred_clients do |referred_client|
    json.id referred_client.id
    json.client_name "#{referred_client.referred_client.label} (#{referred_client.referred_client.email})"
  end
end
