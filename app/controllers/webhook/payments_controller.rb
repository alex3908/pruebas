# frozen_string_literal: true

class Webhook::PaymentsController < ApplicationController
  include QuotationsHelper, FoldersHelper, PaymentsHelper, PaymentProcessorConcern, EntityNamesConcern, OnlinePaymentConcern
  before_action :set_folder, :set_project_entity_names_by_project, :generate, :set_installments, except: [:payment_success, :subscription_success]
  before_action :set_online_payment_service, only: [:new, :create, :new_subscription, :create_subscription]
  before_action :set_description, only: [:new, :create]

  skip_before_action :verify_authenticity_token

  ENCRYPTION_KEY = Rails.application.secrets.encryption_key

  def create
    if request.headers["Content-Type"] == "application/x-www-form-urlencoded;charset=UTF-8" && params[:strResponse].present?

      client = @folder.client
      sku = "#{@project.lot_entity_name} #{@folder.lot.name}"
      amount = @params.dig(:CENTEROFPAYMENTS, :amount)
      reference = @params.dig(:CENTEROFPAYMENTS, :reference)

      if @params.dig(:CENTEROFPAYMENTS, :response) == "approved"
        notify_payment(amount.to_f, reference, client, @online_payment_service, @folder, @next, @quotation, @project)
        save_payment_ticket(@params[:CENTEROFPAYMENTS], @online_payment_service, @description, @next[:concept], amount, @folder, client, session, @project, sku)
      else
        save_payment_ticket(@params[:CENTEROFPAYMENTS], @online_payment_service, @description, @next[:concept], amount, @folder, client, session, @project, sku)
      end

    end
  end

  private
    def set_folder
      data = params.as_json
      decrypted_xml = AesEncryption.new.decrypt(data["strResponse"], ENCRYPTION_KEY)
      decrypted_xml = decrypted_xml.sub("null", "")
      data = Hash.from_xml(decrypted_xml).to_json
      @params = JSON.parse(data).deep_symbolize_keys!
      @payment_reference = PaymentReference.find_by(reference: @params.dig(:CENTEROFPAYMENTS, :reference))
      @folder = Folder.find_by!(id: @payment_reference.folder_id)
      @reference = @folder.id
      @lot = @folder.lot
      @stage = @lot.stage
      @phase = @stage.phase
      @project = @phase.project
      @client = @folder.client
      @enterprise = @stage.enterprise
    end

    def set_online_payment_service
      @online_payment_service ||= @enterprise.online_payment_services.webpay.available.first
      @service_environment = @online_payment_service.environment
    end

    def save_payment_ticket(response, online_payment_service, description, concept_key, amount, folder, client, session, project, sku)
      status = response&.fetch(:response, :error) || :error
      error = response&.fetch(:nb_error, nil)
      status = status == "approved" ? "success" : "error"
      OnlinePaymentTicket.create!(
        online_payment_service_id: online_payment_service.id,
        concept: description,
        concept_key: concept_key,
        amount: amount,
        folder_id: folder.id,
        client_id: client.id,
        token: session.fetch(:np_transaction, nil),
        status: status,
        message: error,
        sku: sku,
        response: response
      )
    end
end
