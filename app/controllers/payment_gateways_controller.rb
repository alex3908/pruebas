# frozen_string_literal: true

class PaymentGatewaysController < ApplicationController
  include QuotationsHelper, FoldersHelper, PaymentsHelper, PaymentProcessorConcern, EntityNamesConcern, OnlinePaymentConcern
  before_action :set_folder, :set_project_entity_names_by_project, :generate, :set_installments, except: [:payment_success, :subscription_success]
  before_action :set_online_payment_service, only: [:new, :create, :new_subscription, :create_subscription]
  before_action :set_description, only: [:new, :create]

  HMAC_SECRET = Rails.application.secrets.secret_payment

  def new
    @title = "Pasarela de pagos"
    @client = get_client(@folder, params[:coowner])
    @coowners = @folder.clients

    address_attributes = @client.address_attributes

    if validate_same_transaction_token

      @confirmation = @online_payment_service.confirm(@transaction_token)
      if @confirmation[:status] == :success
        notify_payment(session.delete(:np_amount), session.delete(:np_transaction), @client)
      end
      amount = @next[:residue].round(2)

      OnlinePaymentTicket.find_by!(token: @transaction_token).update(
        concept: @description,
        concept_key: @next[:concept],
        amount: amount,
        folder_id: @folder.id,
        client_id: @client.id,
        message: transaction_response[:error],
        status: @confirmation
      )
    else
      @missing_fields = []
      address_attributes.each do |k, v|
        if v.blank?
          @missing_fields.push I18n.t("helpers.netpay_billing_attributes.#{k.to_s.underscore}")
        end
      end
    end


    respond_to do |format|
      format.html { render layout: "payment_gateway" }
    end
  end

  def create
    locals = {}

    @title = "Pasarela de pagos"

    client = get_client(@folder, params[:coowner])

    amount = @next[:residue].round(2)

    sku = "#{@project.lot_entity_name} #{@folder.lot.name}"

    response = @online_payment_service.pay(@description,
                                           params[:token_id],
                                           amount,
                                           client,
                                           new_online_payment_url(@folder.id),
                                           sku,
                                           get_address(client),
                                           params[:test_email])

    if response[:status] == "success"

      notify_payment(response[:amount],
                     response[:transaction_token],
                     client,
                     @online_payment_service,
                     @folder,
                     @next,
                     @quotation,
                     @project)

    elsif response[:status] == "review"
      session[:np_transaction] = response[:transaction_token]
      session[:np_amount] = response[:amount]
      locals[:return_url] = response[:redirect]
    else
      locals[:error] = "rejected"
    end
  rescue StandardError => ex
    response[:error] = "payment_error"
    response[:message] = ex.response
  ensure
    save_online_payment_ticket(response, @online_payment_service, @description, @next[:concept], amount, @folder, client, session, @project, sku)
    respond_to do |format|
      format.html { render "payment_gateways/new.html.erb", locals: locals }
      format.js { render "payment_gateways/new.js.erb", locals: locals }
    end
  end

  def payment_success
    respond_to do |format|
      format.html { render layout: "payment_gateway" }
    end
  end

  def subscription_success
    respond_to do |format|
      format.html { render layout: "payment_gateway" }
    end
  end

  private

    def set_folder
      if params[:reference].length == 10
        reference = params[:reference].split("")
        project_reference = reference[0] + reference[1]
        phase_reference = reference[2] + reference[3]
        stage_reference = reference[4] + reference[5]
        lot_reference = reference[-3] + reference[-2] + reference[-1]

        project = Project.find_by(reference: project_reference)
        phase = Phase.find_by(reference: phase_reference, project: project)
        stage = Stage.find_by(reference: stage_reference, phase: phase)
        lot = Lot.find_by(name: lot_reference.to_i, stage: stage)
        folder = Folder.find_by!(lot: lot, step: Step.last_step)
        path = new_online_payment_url(folder.id)
        return redirect_to path, status: :moved_permanently
      end

      @folder = Folder.find_by!(id: params[:reference])
      @reference = @folder.id
      @lot = @folder.lot
      @stage = @lot.stage
      @phase = @stage.phase
      @project = @phase.project
      @client = @folder.client
      @enterprise = @stage.enterprise
    end

    def get_interest_range(number, updates)
      updates.each do |update|
        if number < update[:payments]
          return update[:payments] - number + 1
        end
      end
    end

    def validate_same_transaction_token
      return false unless params[:transaction_token].present?

      params_token = params[:transaction_token]
      session_token = session.fetch(:np_transaction, nil)

      if params_token == session_token
        @transaction_token = session_token
        true
      else
        false
      end
    end

    def validate_token
      token = JWT.decode params[:token], HMAC_SECRET, true, { algorithm: "HS256" }
      @is_update = token[0]["update"] | false

      if @folder.clients.pluck(:id).include? token[0]["client"]
        @client = Client.find(token[0]["client"])
      else
        @client = @folder.client
      end

      if @is_update
        @title = "Actualización de tarjeta"
      else
        @title = "Domiciliación"
      end

      @expiry_count = get_interest_range @next.number, @quotation.interest_payments
    rescue JWT::ExpiredSignature
      @token_invalid = true

      respond_to do |format|
        format.html { render layout: "payment_gateway" }
      end
    end

    def set_online_payment_service
      @online_payment_service ||= @enterprise.online_payment_services.netpay.available.first
      @public_key = @online_payment_service.properties.fetch("charge_public_key")
    end
end
