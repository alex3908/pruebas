# frozen_string_literal: true

class EnterprisesController < ApplicationController
  load_and_authorize_resource
  ENCRYPTION_KEY = Rails.application.secrets.encryption_key

  # GET /enterprises
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @enterprises = Enterprise.all.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  # GET /enterprises/1
  def show
  end

  # GET /enterprises/new
  def new
    @enterprise = Enterprise.new
  end

  # GET /enterprises/1/edit
  def edit
    providers = OnlinePaymentService.providers.dup
    digital_signatures_names = DigitalSignatureService.names.dup
    existing_providers = @enterprise.online_payment_services.map(&:provider)
    existing_providers.each do |p|
      providers.delete p
    end

    existing_digital_signatures = @enterprise.digital_signature_services.map(&:name)
    existing_digital_signatures.each do |p|
      digital_signatures_names.delete p
    end

    @providers = providers.map { |p| [p.second, p.first] }
    @providers_digital_signatures = digital_signatures_names.map { |p| [p.second, p.first] }
  end

  # POST /enterprises
  def create
    if params.dig(:enterprise, :token, :password).present?
      encrypted_data = EncryptDecrypt.encrypt(params.dig(:enterprise, :token, :password), ENCRYPTION_KEY)
      @enterprise.encrypted_password = encrypted_data
    end

    if @enterprise.save
      redirect_to @enterprise, success: "Empresa creada correctamente."
    else
      render :new
    end
  end

  # PATCH/PUT /enterprises/1
  def update
    if params.dig(:enterprise, :token, :password).present?
      encrypted_data = EncryptDecrypt.encrypt(params.dig(:enterprise, :token, :password), ENCRYPTION_KEY)
      params[:enterprise][:encrypted_password] = encrypted_data
    end

    if @enterprise.update(enterprise_params)
      redirect_to @enterprise, success: "Empresa editada correctamente."
    else
      render :edit
    end
  end

  # DELETE /enterprises/1
  def destroy
    @enterprise.destroy
    redirect_to projects_path, success: "Empresa eliminada correctamente."
  end

  private

    def enterprise_params
      params.require(:enterprise).permit(
        :business_name,
        :short_business_name,
        :rfc,
        :state,
        :country,
        :location,
        :street,
        :outdoor_number,
        :indoor_number,
        :colony,
        :postal_code,
        :online_payments_enabled
      )
    end

    def token_params
      params.require(:enterprise).require(:token).permit(:password)
    end
end
