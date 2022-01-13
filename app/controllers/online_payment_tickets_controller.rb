# frozen_string_literal: true

class OnlinePaymentTicketsController < ApplicationController
  include PaymentProcessorConcern
  load_resource

  layout "online_payments"

  def create
    @online_payment_ticket.save!
    @online_payment_service = @online_payment_ticket.online_payment_service

    test_params = @online_payment_service.environment == "test" ? test_response : nil

    client = @online_payment_ticket.client

    address_attributes = client.address_attributes

    if address_attributes.any?(&:blank?) || client.main_phone.blank?
      response[:status] = "error"
      response[:message] = "Faltan datos del cliente. Revise la información del cliente y vuelva a intentar."
      @service_response = response
    else
      address_attributes[:postalCode] = address_attributes.delete(:postal_code)
      address_attributes[:street1] = address_attributes.delete(:street)
      address_attributes[:street2] = address_attributes.delete(:interior_number)
    end

    @service_response = @online_payment_service.pay(
      "#{@online_payment_ticket.concept} (SKU #{@online_payment_ticket.sku})",
      card_token,
      @online_payment_ticket.amount,
      client,
      confirm_online_payment_ticket_url(@online_payment_ticket),
      @online_payment_ticket.sku,
      address_attributes,
      test_params
    ) if @service_response.nil?

    @online_payment_ticket.update(status: @service_response[:status], token: @service_response[:transaction_token], message: @service_response[:message])

    if additional_concept_paid_id.present? && @online_payment_ticket.success?
      create_additional_concept_payment(additional_concept_paid_id)
    elsif additional_concept_paid_id.present? && @online_payment_ticket.review?
      session[:additional_concept] = additional_concept_paid_id
    end

    @provider = @online_payment_service.provider

    render :ticket
  end

  def confirm
    online_payment_service = @online_payment_ticket.online_payment_service

    confirm_response = online_payment_service.confirm(@online_payment_ticket.token, request.query_parameters)

    @online_payment_ticket.update(status: confirm_response[:status], message: confirm_response[:error])

    if session[:additional_concept].present?
      additional_concept_id = session.delete(:additional_concept)
      create_additional_concept_payment(additional_concept_id) if @online_payment_ticket.success?
    end

    @provider = online_payment_service.provider

    render :ticket
  end

  private

    def additional_concept_paid_id
      params.require(:online_payment_ticket).permit(:additional_concept_id).fetch(:additional_concept_id, nil)
    end

    def online_payment_ticket_params
      params.require(:online_payment_ticket).permit(:concept, :concept_key, :amount, :sku, :folder_id, :client_id, :online_payment_service_id, :token)
    end

    def card_token
      params.require(:online_payment_ticket).permit(:token_id).fetch(:token_id)
    end

    def test_response
      params.require(:online_payment_ticket).permit(:test).fetch(:test, nil)
    end
end
