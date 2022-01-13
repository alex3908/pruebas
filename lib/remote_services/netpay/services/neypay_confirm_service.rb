# frozen_string_literal: true

class NetpayConfirmService < NetpayBaseService
  include ConfirmService

  def initialize(token, properties, environment)
    @token = token
    super(properties, environment)
  end

  def confirm
    confirmation_response = RestClient.get(
      gateway_url("gateway-ecommerce/v3/transactions/#{@token}"),
    get_headers(Authorization: charge_secret_key)
    )
    transaction_response = JSON.parse(confirmation_response)
    status = transaction_response.fetch("status", nil)
    error = transaction_response.fetch("error", nil)

    if status == TRANSACTION_STATUS[:chargeable]
      result = :success
      confirmation_response = RestClient.post(
        gateway_url("gateway-ecommerce/v3/charges/#{@token}/confirm"),
          {},
          get_headers(Authorization: charge_secret_key)
      )

      confirmation = JSON.parse(confirmation_response)

      if confirmation["status"] == CONFIRMATION_STATUS[:success]
        result = :success
      elsif confirmation["status"] == CONFIRMATION_STATUS[:error] # Transaction rejected by bank rules
        result = :error
      end
    else
      result = :failed
    end

    { status: result, error: error }

rescue RestClient::Exception => ex
  result = :failed
  Bugsnag.notify(ex) do |report|
    report.add_tab(:netpay, {
        token: @token,
        response: ex&.response
    })
  end
ensure
  return result
  end
end
