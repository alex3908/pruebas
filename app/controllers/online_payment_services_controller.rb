# frozen_string_literal: true

class OnlinePaymentServicesController < ApplicationController
  include PaymentsHelper

  load_and_authorize_resource :enterprise, except: [:form, :select, :subscription_form, :subscribe]
  load_resource through: :enterprise, except: [:form, :select, :subscription_form, :subscribe]

  before_action :set_payment_methods, :set_branches, only: [:edit, :update]

  layout "online_payments", only: [:form, :select, :subscription_form, :subscribe]

  HMAC_SECRET = Rails.application.secrets.secret_payment
  ENCRYPTION_KEY = Rails.application.secrets.encryption_key

  def create
    if @online_payment_service.save
      flash[:success] = "El servicio fue inicializado correctamente, asegúrate de completar la configuración para que pueda ser usado"
      redirect_to edit_enterprise_online_payment_service_path(@enterprise, @online_payment_service)
    else
      flash[:error] = "No se pudo inicializar el servicio"
      redirect_to edit_enterprise_path(@enterprise)
    end
  end

  def edit
    locals = { return_url: edit_enterprise_path(@enterprise), values: {} }

    render locals: locals
  end

  def update
    if @online_payment_service.update(online_payment_service_params)
      flash[:success] = "El servicio fue actualizado correctamente."
      redirect_to edit_enterprise_online_payment_service_path(@enterprise, @online_payment_service)
    else
      render :edit
    end
  end

  def form
    @online_payment_service = OnlinePaymentService.find(online_payment_params[:online_payment_service_id])
    @client = Client.find(online_payment_params[:client_id])
    @missing_fields = missing_client_attributes

    @subscription_concept = params.fetch(:concept, nil)
    @folder = Folder.find(params[:folder_id])
    @lot = @folder.lot
    @stage = @lot.stage
    @phase = @stage.phase
    @project = @phase.project

    @online_payment = online_payment_params
    @online_payment[:folder_id] = params[:folder_id]

    render :form, locals: { service: @online_payment_service.creator }
  end

  def subscription_form
    @online_payment_service = OnlinePaymentService.find(params[:service_id])
    @folder = Folder.find(params[:id])
    @lot = @folder.lot
    @stage = @lot.stage
    @phase = @stage.phase
    @project = @phase.project

    begin
      token = JWT.decode params[:token], HMAC_SECRET, true, { algorithm: "HS256" }
      subscription_data = token[0]

      @client = @folder.clients.find { |c| c.id == subscription_data["client"] }
      @missing_fields = missing_client_attributes

      if @client.nil?
        @client = @folder.client
      end

      @concept = subscription_data["concept"]
      @concept_key = subscription_data["concept_key"]
      @start_date = subscription_data["start_date"]
      @amount = subscription_data["amount"]
      @expiry_count = subscription_data["months_to_subscribe"]
    rescue JWT::ExpiredSignature
      @token_invalid = true

      respond_to do |format|
        format.html { render "payment_gateways/new_subscription", layout: "payment_gateway" }
      end
    rescue StandardError => ex
      Bugsnag.notify(ex)
      render :form, locals: { error: "Ha ocurrido un error al cargar el formulario. Por favor, intente más tarde." }
    else
      render :form, locals: { service: @online_payment_service.creator, subscription: true }
    end
  end

  def subscribe
    @online_payment_service = OnlinePaymentService.find(params[:id])
    @folder = Folder.find(params[:folder_id])
    @project = @folder.lot.project
    locals = {}

    client = Client.find(subscription_params[:client_id])

    subscription_response = @online_payment_service.subscribe(
      subscription_params[:token_id],
      subscription_params[:amount],
      subscription_params[:concept],
      subscription_params[:expiry_count],
      subscription_params[:start_date],
      subscription_params[:identifier],
      client
    )

    if subscription_response["status"] == "A"
      @subscription = @folder.subscriptions.build(subscription_attributes(subscription_response))
      @subscription.online_payment_service = @online_payment_service
      @subscription.concept_key = subscription_params[:concept_key]
      @subscription.client = client
      @subscription.folder = @folder
      @subscription.months_to_subscribe = subscription_params[:expiry_count]
      @subscription.amount = subscription_params[:amount]
      @subscription.save
      SubscriptionMailer.confirm_subscription(client.email, client, @folder, DateTime.parse(subscription_params[:start_date]).strftime("%d"), @project.project_entity_name, @project.phase_entity_name, @project.stage_entity_name).deliver_later
      locals[:status] = "success"
    else
      locals[:status] = "rejected"
    end
  rescue StandardError => ex
    locals[:error] = "error"
    locals[:message] = ex.message
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, message: ex.message })
    end
  ensure
    render :subscription_response, locals: locals
  end

  def destroy
    @online_payment_service.destroy
    respond_to do |format|
      format.html { redirect_to edit_enterprise_path(@enterprise), notice: "La plantilla fue eliminada correctamente." }
      format.json { head :no_content }
    end
  end

  private
    def has_stp_clabe_set?
      properties = @online_payment_service.properties || {}
      @online_payment_service.stp? && properties.has_key?("clabe") && !properties["clabe"].blank?
    end

    def missing_client_attributes
      missing_fields = []
      @client.address_attributes.each do |k, v|
        if v.blank?
          missing_fields.push I18n.t("helpers.netpay_billing_attributes.#{k.to_s.underscore}")
        end
      end

      missing_fields
    end

    def online_payment_params
      params.require(:online_payment).permit(:online_payment_service_id,
                                             :client_id,
                                             :concept,
                                             :amount,
                                             :sku,
                                             :concept_key,
                                             :is_additional_concept,
                                             :additional_concept_id)
    end

    def subscription_params
      params.require(:subscription).permit(:token_id, :concept, :concept_key, :amount, :expiry_count, :start_date, :identifier, :client_id)
    end

    def subscription_attributes(service_response)
      {
        subscription_id: service_response["id"],
        status: service_response["status"],
        exp_year: service_response["cardToken"]["expYear"],
        exp_month: service_response["cardToken"]["expMonth"],
        last_four_digits: service_response["cardToken"]["lastFourDigits"],
        last_update: service_response["createdAt"],
        billing_start: service_response["billingStart"],
        billing_end: service_response["billingEnd"],
      }
    end

    def set_payment_methods
      @payment_methods = PaymentMethod.visible
    end

    def set_branches
      @branches = Branch.all
    end

    def online_payment_service_params
      params.require(:online_payment_service).permit(:provider, :environment, :bank_account_id, :payment_method_id, :branch_id, properties: {})
    end
end
