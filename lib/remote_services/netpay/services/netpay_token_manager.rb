# frozen_string_literal: true

class NetpayTokenManager < NetpayBaseService
  def update_client_token(client_online_id, token)
    subscription_body = {
    token: token,
    preAuth: true
    }

    update_response = RestClient.put gateway_url("gateway-ecommerce/v3/clients/#{client_online_id}/token"), subscription_body.to_json, get_headers(Authorization: loop_secret_key)

    JSON.parse update_response
  end

  def delete_client_token(client_online_id, token)
    RestClient.delete gateway_url("gateway-ecommerce/v3/clients/#{client_online_id}/token/#{token}"), get_headers(Authorization: loop_secret_key)
  end
end
