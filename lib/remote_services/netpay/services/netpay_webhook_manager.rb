# frozen_string_literal: true

class NetpayWebhookService < NetpayBaseService
  include WebhookManager

  def delete_webhook(url)
    return if loop_secret_key.blank?

    response = JSON.parse RestClient.get(gateway_url("gateway-ecommerce/v3/webhooks/"), get_headers(Authorization: loop_secret_key))

    if response.has_key?("id") && response.has_key?("webhook")
      RestClient.delete(gateway_url("gateway-ecommerce/v3/webhooks/"), get_headers(Authorization: loop_secret_key))
    end
rescue RestClient::Exception => ex
  json_response = JSON.parse(ex.response)
  is_empty_error = json_response["message"].include?("Index") && json_response["message"].include?("Size")

  return if is_empty_error

  Bugsnag.notify(ex) do |report|
    report.add_tab(:netpay_api_response, JSON.parse(ex.response)) if ex.respond_to?(:response)
  end
  end

  def create_webhook(url)
    return webhook_result(:error, :missing_secret_key) if loop_secret_key.blank?

    resp = JSON.parse RestClient.put(
      gateway_url("gateway-ecommerce/v3/webhooks/"),
    {
        webhook: url
    }.to_json,
    get_headers(Authorization: loop_secret_key)
    )

    if resp.has_key?("id") && resp.has_key?("webhook")
      webhook_result(:success)
    else
      raise NetpayApiError.new(resp), "Couldn't create webhook, is id or webhook missing from response?"
    end
rescue NetpayApiError => ex
  Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, JSON.parse(ex.api_response)) if ex.respond_to?(:response)
    end

  webhook_result(:api_error, ex.message)
rescue RestClient::Exception => ex
  Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, JSON.parse(ex.response)) if ex.respond_to?(:response)
    end

  webhook_result(:error, ex.message)
  end

    private

      def webhook_result(status, error_message = nil)
        OpenStruct.new(status: status, error_message: error_message)
      end
end
