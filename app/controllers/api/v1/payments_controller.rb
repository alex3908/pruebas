# frozen_string_literal: true

class Api::V1::PaymentsController < ApplicationController
  before_action :set_folder, :set_installments, :set_online_payment_service
  skip_before_action :verify_authenticity_token

  include GenerateXml, OnlinePaymentConcern

  ENCRYPTION_KEY = Rails.application.secrets.encryption_key
  FIXED_CHAIN = Rails.application.secrets.fixed_chain

  def create
    if params[:data].present? && params.dig(:data, :reference).present?

      amount = @next.residue.round(2)
      folder_id = params.dig(:data, :folder_id)
      reference = params.dig(:data, :reference)
      fh_vigencia = params.dig(:data, :fh_vigencia)
      client = get_client(@folder, "")
      sku = ""
      test_params = @online_payment_service.environment
      address = ""
      data3ds = { data3ds: params.dig(:data, :data3ds) }


      response = @online_payment_service.pay(fh_vigencia, reference, amount, client, data3ds, sku, address, test_params)

      if response[:status] == "success"
        PaymentReference.create(
          reference: reference,
          folder_id: folder_id,
          response: response[:formatted_response]
        )
        render json: response
      else
        render json: response
      end
    end
  end

  private

    def set_folder
      @folder = Folder.find_by!(id: params.dig(:data, :folder_id))
      @reference = @folder.id
      @lot = @folder.lot
      @stage = @lot.stage
      @phase = @stage.phase
      @project = @phase.project
      @client = @folder.client
      @enterprise = @stage.enterprise
    end

    def set_installments
      @overdue = false
      @folder.persisted_installments.each do |installment|
        actual = installment

        concept = actual.concept
        total_paid = actual.total_paid
        if total_paid < installment.total.round(2)
          @overdue = true if installment.date.strftime("%Y/%m/%d") < Time.zone.now.strftime("%Y/%m/%d")
          @next = set_next_installment(installment, concept, installment.total.round(2) - total_paid) if @next.nil?
        end
      end
    end

    def set_online_payment_service
      @online_payment_service ||= @enterprise.online_payment_services.webpay.available.first
    end

    def set_next_installment(installment, _concept, residue)
      installment.residue = residue
      installment
    end
end
