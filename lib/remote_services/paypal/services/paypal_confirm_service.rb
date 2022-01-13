# frozen_string_literal: true

class PaypalConfirmService < PaypalBaseService
  include ConfirmService
  def initialize(token, query_params, properties, environment)
    @token = token
    @query_params = query_params
    super(properties, environment)
  end

  def confirm
    PayPal::SDK::REST.set_config(mode: mode, client_id: client_id, client_secret: secret_token)

    payment = Payment.find(@token)

    response = {}

    if payment.execute(payer_id: @query_params["PayerID"])
      response[:status] = :success
    else
      response[:status] = :failed
      response[:message] = payment.error
    end

    response
  end
end
