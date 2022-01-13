# frozen_string_literal: true

class NetpayPlanManager < NetpayBaseService
  include PlanManager
  def get_plan(plan_id)
    response = RestClient.get gateway_url("gateway-ecommerce/v3/plans/#{plan_id}"), get_headers(Authorization: loop_secret_key)

    JSON.parse response
  end

  def create_plan(name, amount, start_day, total_payments_count, identifier)
    plan_body = {
    name: name,
    amount: amount,
    currency: "MXN",
    frecuency: 1,
    interval: "MONTHLY",
    expiryCount: total_payments_count,
    trialDays: 0,
    variableAmount: true,
    dayStartPayment: start_day,
    selfRetries: false,
    selfRenewal: false,
    identifier: identifier
    }

    netpay_plan = RestClient.post gateway_url("gateway-ecommerce/v3/plans"), plan_body.to_json, { content_type: :json, Authorization: loop_secret_key, accept: :json }
    netpay_plan = JSON.parse netpay_plan

    netpay_plan["id"]
  end

  def update_plan_amount(plan_id, amount, concept)
    plan_body = {
    amount: amount,
    currency: "MXN",
    name: concept
    }

    netpay_plan = RestClient.put gateway_url("gateway-ecommerce/v3/plans/#{plan_id}"), plan_body.to_json, { content_type: :json, Authorization: loop_secret_key, accept: :json }
    JSON.parse netpay_plan
  end
end
