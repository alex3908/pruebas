# frozen_string_literal: true

class PaypalPaymentProcessor < PaypalBaseService
  include PaymentProcessor


  def initialize(concept, token, amount, client, url, sku, test = nil, properties, environment)
    @concept = concept
    @token = token
    @amount = amount
    @client = client
    @url = url
    @sku = sku
    @test = test
    super(properties, environment)
  end

  def pay
    PayPal::SDK::REST.set_config(mode: mode, client_id: client_id, client_secret: secret_token)

    payment = Payment.new(
      intent: "sale",
      payer: {
        payment_method: "paypal"
      },
      redirect_urls: {
        return_url: @url,
        cancel_url: @url
      },
      transactions: [{
        item_list: {
          items: [{
            name: @concept,
            sku: @sku,
            price: @amount,
            currency: "MXN",
            quantity: 1
          }]
        },
        amount: {
          total: @amount,
          currency: "MXN"
        },
        description: @concept
      }]
    )
    payment.create

    response = {}

    if payment.create
      response[:transaction_token] = payment.id
      response[:status] = :review
      response[:redirect] = payment.links.find { |v| v.method == "REDIRECT" }.href
    else
      response[:status] = :error
      response[:message] = payment.error
    end

    response
  end
end
