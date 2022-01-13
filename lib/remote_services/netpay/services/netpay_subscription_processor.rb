# frozen_string_literal: true

class NetpaySubscriptionProcessor < NetpayBaseService
  include SubscriptionProcessor

  def initialize(token, amount, concept, expiry_count, start_date, identifier, client, properties, environment)
    @token = token
    @amount = amount
    @concept = concept
    @expiry_count = expiry_count
    @start_date = start_date
    @identifier
    @client = client
    super(properties, environment)
  end

  def subscribe
    @start_date = DateTime.parse(@start_date)

    plan_body = {
    amount: @amount,
    currency: "MXN",
    frecuency: 1,
    interval: "MONTHLY",
    name: @concept,
    expiryCount: @expiry_count,
    trialDays: 0,
    variableAmount: false,
    dayStartPayment: @start_date.strftime("%d"),
    identifier: @identifier
    }
    netpay_plan = RestClient.post gateway_url("gateway-ecommerce/v3/plans"), plan_body.to_json, { content_type: :json, Authorization: loop_secret_key, accept: :json }
    netpay_plan = JSON.parse netpay_plan

    subscriptions_body = {
    client: {
        id: client_online_id,
        paymentSource: {
        source: @token
        }
    },
    expiryCount: @expiry_count,
    selfRenewal: false,
    billingStart: @start_date.strftime("%Y-%m-%d")
    }

    netpay_subscriptions = RestClient.post gateway_url("gateway-ecommerce/v3/plans/#{netpay_plan["id"]}/subscriptions"), subscriptions_body.to_json, { content_type: :json, Authorization: loop_secret_key, accept: :json }
    JSON.parse netpay_subscriptions
rescue RestClient::Exception => ex
  Bugsnag.notify(ex)
  end
end
