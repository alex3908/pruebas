# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  include EntityNamesConcern
  load_and_authorize_resource except: [:invite, :new, :create]
  before_action :set_folder_and_parents, :set_project_entity_names_by_project
  before_action :set_subscription_service
  layout "online_payments", only: [:new, :create, :update]

  HMAC_SECRET = Rails.application.secrets.secret_payment

  def new
    if @folder.active_subscription? && @folder.subscription.card_updatable?
      @client = @folder.subscription.client
      @subscription = @folder.subscription
      @subscription_plans = @subscription.subscription_plans
    elsif @folder.active_subscription?
      @subscription = @folder.subscription
      @subscription_plans = @subscription.subscription_plans
    elsif @folder.clients.size == 1
      @client = @folder.clients.first
    elsif !params[:client_id].blank?
      @client = @folder.clients.find { |c| c.id == params[:client_id].to_i }
    else
      @clients = @folder.clients
    end

    @subscription_plans ||= build_plans

    render :new
  end

  def create
    client = @folder.clients.find { |c| c.id == subscription_params[:client_id].to_i }

    create_or_update_client(client, subscription_params[:token_id], @online_payment_service)

    @subscription_plans = build_plans
    plan_id = create_plan(@subscription_plans.first, @online_payment_service, @subscription_plans.inject(0) { |sum, p| sum + p.payments_count })
    subscription_response = create_subscription(plan_id, subscription_params[:token_id], client.online_id, @online_payment_service)

    client.reload
    update_subscription_amount(subscription_response["id"], @subscription_plans.first.amount, @online_payment_service)

    Subscription.create(
      folder: @folder,
      client: client,
      subscription_id: subscription_response["id"],
      online_plan_id: plan_id,
      exp_year: subscription_response["cardToken"]["expYear"],
      exp_month: subscription_response["cardToken"]["expMonth"],
      last_four_digits: subscription_response["cardToken"]["lastFourDigits"],
      online_payment_service: @online_payment_service,
      subscription_plans: @subscription_plans,
      status: subscription_response["status"],
      billing_start: subscription_response["billingStart"],
      billing_end: subscription_response["billingEnd"],
    )

    locals = { subscription_response: :success }
  rescue RestClient::Exception => ex

    locals = { subscription_response: :error, message: ex.response }

    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, request: JSON.parse(ex.response.request.args[:payload]), response: JSON.parse(ex.response) }) if ex.respond_to?(:response)
    end
  rescue StandardError => ex
    locals = { subscription_response: :error, message: ex.message }
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, message: ex.message })
    end
  ensure
    render :new, locals: locals
  end

  def update
    @subscription = @folder.subscription
    client = @subscription.client
    @subscription_plans = @subscription.subscription_plans
    token_manager = @online_payment_service.token_manager
    client_response = token_manager.update_client_token(client.online_id, subscription_params[:token_id])

    @subscription.update(
      allow_update: false,
      exp_year: client_response["expYear"],
      exp_month: client_response["expMonth"],
      last_four_digits: client_response["lastFourDigits"],
    )

    locals = { update_response: :success }
  rescue RestClient::Exception => ex
    locals = { update_response: :failed, message: ex.response }

    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, request: JSON.parse(ex.response.request.args[:payload]), response: JSON.parse(ex.response) }) if ex.respond_to?(:response)
    end
  rescue StandardError => ex
    locals = { update_response: :error, message: ex.message }
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, message: ex.message })
    end
  ensure
    render :new, locals: locals
  end

  def invite
    client = Client.find(invite_params[:client_id])
    send_subscription(client) unless @folder.active_subscription?

    respond_to do |format|
      format.js { render "subscriptions/invite" }
      format.json { render json: true, status: :ok }
    end
  rescue Exception => ex
    raise ex
    Bugsnag.notify(ex)
    respond_to do |format|
      format.js { render "subscriptions/invite", locals: { error: "invitation_error" } }
      format.json { render json: error, status: :unprocessable_entity }
    end
  end

  def invite_update
    @client = @subscription.client
    @subscription.update(allow_update: true)

    SubscriptionMailer.card_soon_to_expire(@client.email, @client, @subscription, @project_singular, @phase_singular, @stage_singular).deliver_later
    respond_to do |format|
      format.json { render json: true, status: :created }
    end
  rescue Exception => ex
    Bugsnag.notify(ex)
    respond_to do |format|
      format.json { render json: error, status: :unprocessable_entity }
    end
  end

  def destroy
    locals = {}
    @online_payment_service = @folder.stage.enterprise.online_payment_services.where(provider: :netpay).available.first
    secret_key = @online_payment_service.properties.fetch("loop_secret_key")
    netpay_subscriptions = RestClient.put payment_gateway_url("gateway-ecommerce/v3/subscriptions/#{@subscription.subscription_id}/cancel", @online_payment_service.environment), "", { content_type: :json, Authorization: secret_key, accept: :json }
    netpay_subscriptions = JSON.parse netpay_subscriptions

    if netpay_subscriptions["status"] == "C"
      @subscription.update(status: netpay_subscriptions["status"])
      locals[:message] = "destroy_success"
    else
      locals[:message] = "destroy_error"
    end
  rescue RestClient::Exception => ex
    locals[:error] = "destroy_error"
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, request: JSON.parse(ex.response.request.args[:payload]), response: JSON.parse(ex.response) }) if ex.respond_to?(:response)
    end
  rescue StandardError => ex
    locals[:message] = "destroy_error"
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { business_name: @online_payment_service&.enterprise&.business_name, message: ex.message })
    end
  ensure
    respond_to do |format|
      format.json { render json: locals, status: :ok }
    end
  end

  private
    def create_plan(plan, online_payment_service, total_payments_count)
      online_payment_service.plan_manager.create_plan("Domiciliación de expediente", plan.amount, plan.start_date.strftime("%d"), total_payments_count, "folder-#{@folder.id}")
    end

    def create_subscription(plan_id, token_id, client_online_id, online_payment_service)
      online_payment_service.suscription_manager.subscribe_variable(plan_id, token_id, client_online_id, new_subscription_path(folder_id: @folder.id))
    end

    def update_subscription_amount(subscription_id, amount, online_payment_service)
      online_payment_service.suscription_manager.update_subscription_amount(subscription_id, amount)
    end

    def create_or_update_client(client, token, online_payment_service)
      online_id = online_payment_service.client_service.get_client(client, token)
      client.update(online_id: online_id)
    end

    def build_plans
      down_payment_plans = @folder.down_payment_installment_updates.map { |installments| build_subscription_plan(installments) }
      financing_plans = @folder.financing_installment_updates.map { |installments| build_subscription_plan(installments) }

      [
        build_subscription_plan(@folder.installments.initial_payment),
        *down_payment_plans,
        *financing_plans
      ].compact
    end

    def set_folder_and_parents
      @folder = Folder.find(params[:folder_id])
      @project = @folder.project
      @phase = @folder.phase
      @stage = @folder.stage
      @lot = @folder.lot
    end

    def set_subscription_service
      @online_payment_service = @folder.stage.enterprise.online_payment_services.netpay.take
    end

    def send_subscription(client)
      SubscriptionMailer.subscription_invitation(client.email, client, @folder, @project_singular, @phase_singular, @stage_singular).deliver_later
    end

    def build_subscription_plan(unsorted_installments)
      installments = unsorted_installments.sort_by(&:date)
      installments_count = installments.count(&:is_unpaid?)
      return nil if installments_count == 0

      SubscriptionPlan.new(
        amount: installments.first.total,
        payments_count: installments.count(&:is_unpaid?),
        start_date: installments.first.date,
        end_date: installments.last.date,
        concept_description: installments.first.concept
      )
    end

    def subscription_params
      params.require(:subscription).permit(:client_id, :concept, :amount, :months_to_subscribe, :billing_start, :concept_key, :token_id)
    end

    def invite_params
      params.require(:invite).permit(:client_id)
    end
end
