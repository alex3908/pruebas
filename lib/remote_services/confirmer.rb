# frozen_string_literal: true

class Confirmer
  def initialize(token, query_params, provider, properties, environment)
    @token = token
    @query_params = query_params
    @provider = provider
    @properties = properties
    @environment = environment
  end

  def compute_confirmation
    selected_provider = select_provider
    return selected_provider if selected_provider == "no_available"
    selected_provider.confirm
  end

    private

      def select_provider
        case @provider
        when "netpay"
          confirm_service = NetpayConfirmService.new(@token, @properties, @environment)
        when "paypal"
          confirm_service = PaypalConfirmService.new(@token, @query_params, @properties, @environment)
        else
          return "no_available"
        end
        confirm_service
      end
end
