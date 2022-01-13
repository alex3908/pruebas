# frozen_string_literal: true

class ClientsApi::V1::PaymentMethodsController < ClientsAPI::V1::BaseController
  def index
    payment_methods = PaymentMethod.all
    render json: payment_methods
  end
end
