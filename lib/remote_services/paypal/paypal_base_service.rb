# frozen_string_literal: true

require "paypal-sdk-rest"

class PaypalBaseService < RemoteService
  include PayPal::SDK::REST

  def get_fields
    [
      :client_id,
      :client_secret
    ]
  end

  def client_id
    properties["client_id"]
  end

  def secret_token
    properties["client_secret"]
  end

    private

      def mode
        if environment? :test
          "sandbox"
        else
          "live"
        end
      end
end
