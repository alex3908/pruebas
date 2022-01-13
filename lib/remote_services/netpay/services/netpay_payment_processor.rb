# frozen_string_literal: true

class NetpayPaymentProcessor < NetpayBaseService
  include PaymentProcessor

  def initialize(description, token, amount, client, redirect_url, address, test, properties, environment)
    @description = description
    @token = token
    @amount = amount
    @client = client
    @redirect_url = redirect_url
    @address = address
    @test = test
    super(properties, environment)
  end

  def pay
    response = {}

    email =  mode == "test" ? get_email(@test) : @client.email

    charge_body = {
    description: @description,
    source: @token,
    paymentMethod: "card",
    amount: @amount,
    currency: "MXN",
    billing: {
        firstName: I18n.transliterate(@client.name),
        lastName: I18n.transliterate("#{@client.first_surname} #{@client.second_surname}"),
        email: email,
        phone: @client.main_phone.gsub(/[^.0-9]+/, ""),
        address: @address
    },
    redirect3dsUri: @redirect_url,
    saveCard: false
    }

    charge = RestClient.post(gateway_url("gateway-ecommerce/v3/charges"), charge_body.to_json, get_headers(Authorization: charge_secret_key))
    rescue RestClient::Exception => ex

      Bugsnag.notify(ex) do |report|
        report.add_tab(:netpay_api_response, JSON.parse(ex.response)) if ex.respond_to?(:response)
      end

      if ex.http_code == 400
        response[:error] = "data_invalid"
        response[:message] = "Los datos del cliente son inválidos. Revise la información del cliente y vuelva a intentar."
      elsif ex.http_code == 404
        response[:error] = "not_found"
        response[:message] = "Recurso no encontrado."

      else
        response[:message] = ex.response
        response[:error] = "payment_error"
      end

    rescue StandardError => ex

      response[:error] = "payment_error"
      response[:message] = ex.response

      Bugsnag.notify(ex) do |report|
        report.add_tab(:netpay_api_response, JSON.parse(ex.response)) if ex.respond_to?(:response)
      end
  else

    charge = JSON.parse(charge)
    if charge["status"] == "success"
      response[:transaction_token] = charge["transactionTokenId"]
    elsif charge["status"] == "review"
      response[:redirect] = charge["returnUrl"]
      response[:transaction_token] = charge["transactionTokenId"]
    end
    response[:amount] = charge["amount"]
    response[:status] = charge["status"]
    response[:message] = charge["error"]
    ensure
      return response
    end
end
