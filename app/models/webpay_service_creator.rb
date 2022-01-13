# frozen_string_literal: true

class WebpayServiceCreator < PaymentServiceCreator
  def create_payment_service(properties, environment)
    WebpayPaymentService.new(properties, environment)
  end

  def get_fields
    [
      :key_code
    ]
  end
end
