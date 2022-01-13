# frozen_string_literal: true

class WebpayBaseService < RemoteService
  include BaseService

  GATEWAY_URLS = {
      "production" => "",
      "test" => "https://wppsandbox.mit.com.mx"
  }

  CONFIRMATION_STATUS = {
      success: "success",
      error: "error"
  }

  TEST_EMAIL = {
      dev: "test@webpay.com.mx"
  }

  def get_fields
    [
      :key_code
    ]
  end

  private
    def gateway_url(to_append)
      URI.join(GATEWAY_URLS[mode], to_append).to_s
    end

    def get_headers
      {
        content_type: "application/x-www-form-urlencoded",
        cache_control: "no-cache"
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
