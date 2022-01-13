# frozen_string_literal: true


class NetpayBaseService < RemoteService
  include Exceptions
  include BaseService

  GATEWAY_URLS = {
      "production" => "https://suite.netpay.com.mx",
      "test" => "https://gateway-154.netpaydev.com"
  }

  TRANSACTION_STATUS = {
      chargeable: "CHARGEABLE",
      failed: "FAILED"
  }

  CONFIRMATION_STATUS = {
      success: "success",
      error: "error"
  }

  TEST_EMAIL = {
      accept: "accept@netpay.com.mx",
      reject: "reject@netpay.com.mx",
      review: "review@netpay.com.mx"
  }

  def get_fields
    [
      :charge_secret_key,
      :charge_public_key,
      :loop_secret_key,
      :loop_public_key
    ]
  end

  def charge_public_key
    properties["charge_public_key"]
  end

  def charge_secret_key
    properties["charge_secret_key"]
  end

  def loop_public_key
    properties["loop_public_key"]
  end

  def loop_secret_key
    properties["loop_secret_key"]
  end

    private
      def gateway_url(to_append)
        URI.join(GATEWAY_URLS[mode], to_append).to_s
      end

      def get_headers(opts = {})
        {
            content_type: opts[:content_type] || :json,
            Authorization: opts[:Authorization] || "",
            accept: opts[:accept] || :json
        }
      end

      def get_email(test_type)
        if mode == "test"
          TEST_EMAIL[test_type.to_sym]
        end
      end

      def mode
        environment
      end
end
