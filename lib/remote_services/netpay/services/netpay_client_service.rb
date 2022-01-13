# frozen_string_literal: true

class NetpayClientService < NetpayBaseService
  include ClientService

  def get_client(client, token)
    client_body = {
    firstName: I18n.transliterate(client.name),
    lastName: I18n.transliterate("#{client.first_surname} #{client.second_surname}"),
    phone: client.main_phone.gsub(/[^.0-9]+/, ""),
    email: client.email,
    paymentSource: {
        source: token,
        type: "card"
    },
    identifier: client.id
    }

    if client.online_id.blank?
      netpay_client = RestClient.post gateway_url("gateway-ecommerce/v3/clients"), client_body.to_json, get_headers(Authorization: loop_secret_key)
    else
      netpay_client = RestClient.put gateway_url("gateway-ecommerce/v3/clients/#{client.online_id}"), client_body.to_json, get_headers(Authorization: loop_secret_key)
    end

    netpay_client = JSON.parse netpay_client

    netpay_client["id"]
  end
end
