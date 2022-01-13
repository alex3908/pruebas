# frozen_string_literal: true

class Payer
  def initialize(description, token, amount, client, redirect_url, sku, address, test, provider, properties, environment)
    @description = description
    @token = token
    @amount = amount
    @client = client
    @redirect_url = redirect_url
    @sku = sku
    @address = address
    @test = test
    @provider = provider
    @properties = properties
    @environment = environment
  end

  def compute_payment
    selected_provider = select_provider
    return selected_provider if selected_provider == "no_available"
    selected_provider.pay
  end

    private

      def select_provider
        case @provider
        when "netpay"
          payment_processor = NetpayPaymentProcessor.new(@description, @token, @amount, @client, @redirect_url, @address, @test, @properties, @environment)
        when "paypal"
          payment_processor = PaypalPaymentProcessor.new(@description, @token, @amount, @client, @redirect_url, @sku, @test, @properties, @environment)
        when "webpay"
          payment_processor = WebpayPaymentProcessor.new(@description, @token, @amount, @client, @redirect_url, @test, @properties, @environment)
        else
          return "no_available"
        end
        payment_processor
      end
end
