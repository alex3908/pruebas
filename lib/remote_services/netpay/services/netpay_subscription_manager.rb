# frozen_string_literal: true

class NetpaySubscriptionManager < NetpayBaseService
  include SubscriptionManager

  def get_subscription(subscription_id)
    response = RestClient.get gateway_url("gateway-ecommerce/v3/subscriptions/#{subscription_id}"), get_headers(Authorization: loop_secret_key)

    JSON.parse response
  end


  def subscribe_variable(plan_id, token, client_online_id, redirect_uri)
    subscriptions_body = {
    client: {
        id: client_online_id,
        paymentSource: {
        source: token
        }
    },
    redirect3dsUri: redirect_uri
    }

    netpay_subscription = RestClient.post gateway_url("gateway-ecommerce/v3/plans/#{plan_id}/subscriptions"), subscriptions_body.to_json, { content_type: :json, Authorization: loop_secret_key, accept: :json }

    JSON.parse netpay_subscription
  end

  def update_subscription_amount(subscription_id, amount)
    subscription_body = {
    amount: amount
    }

    update_response = RestClient.put gateway_url("gateway-ecommerce/v3/subscriptions/#{subscription_id}"), subscription_body.to_json, get_headers(Authorization: loop_secret_key)

    JSON.parse update_response
  end


  def update_subscription(subscription_id, client_online_id, token)
    subscription_body = {
    client: {
        id: client_online_id,
        paymentSource: {
        source: token
        }
    }
    }

    update_response = RestClient.put gateway_url("gateway-ecommerce/v3/subscriptions/#{subscription_id}"), subscription_body.to_json, get_headers(Authorization: loop_secret_key)

    JSON.parse update_response
  end

  def cancel_subscription(subscription_id)
    RestClient.put gateway_url("gateway-ecommerce/v3/subscriptions/#{subscription_id}/cancel"), get_headers(Authorization: loop_secret_key)
  end
end
