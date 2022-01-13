# frozen_string_literal: true

class ClientsController < ApplicationController
  include ClientsHelper, HubspotConcern, QuoteLogsHelper
  load_and_authorize_resource except: [:download_import_template, :confirm_email]
  before_action :validate_email, only: [:create]
  before_action :verify_access, only: [:show, :edit, :update, :delete_suppression]
  before_action :set_lead_sources, only: [:edit, :new, :create, :update]
  before_action :set_identification_types, only: [:edit, :new, :create, :update]
  before_action :client_selection, only: [:index, :autocomplete]
  before_action :set_client_user_concepts, only: [:show]
  before_action :set_client_documents, only: [:edit, :update]
  helper_method :get_translate, :sort_column, :sort_direction, :translate_gender
  before_action :clients_logs_show, only: [:index, :create, :update, :show, :destroy]

  layout "custom_layout", only: [:confirm_email]

  # GET /clients
  def index
    @clients = @clients.includes(:client_users).search(params).order(sort_column + " " + sort_direction).paginate(page: params[:page], per_page: @per_page)

    @client_user_concepts = ClientUserConcept.all
  end

  def autocomplete
    respond_to do |format|
      format.json {
        render json: @clients.autocomplete(params[:search])
      }
    end
  end

  def autocomplete_by_email
    respond_to do |format|
      format.json {
        render json: @clients.autocomplete_by_email(params[:search])
      }
    end
  end

  # GET /clients/1
  def show
    @cash_backs = @client.cash_backs.order(created_at: :desc)
    @branches = Branch.all.order(id: :asc)
    @filter_path = client_path(@client)
    @projects = Project.includes(phases: :stages).order(id: :asc)

    page = params[:model] == QuoteLog.name ? 1 : params[:page]

    @folders = Folder.where(client: @client).set_params(params, sort_column, sort_direction).paginate(page: page, per_page: @per_page)

    @logs = Log.where(element: "client", element_id: @client.id).includes(:user) if can?(:see_binnacle, Client)
    @user = User.includes(:structure).find_by(id: @client.sales_executive.id)

    @ppage = params[:ppage].to_i < 1 ? @per_page_default : params[:ppage] || @per_page_default

    if params[:model] == QuoteLog.name || params[:model].nil?
      @quote_logs = QuoteLog.order(created_at: :asc).where(client: @client).paginate(page: params[:page], per_page: @ppage)
    end
  end

  # GET /clients/new
  def new
    @client.person = Client::PHYSICAL
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients/validate_email
  def validate_email_json
    email = params[:email].downcase
    found_in_database = Client.find_by(email: email).present?
    found_in_hubspot = false

    if is_hubspot_enabled?
      begin
        contact = Hubspot::Contact.find_by_email(email)
        owner = Hubspot::Owner.find_by_email(current_user.email)
        is_same_owner = contact&.properties&.dig(:hubspot_owner_id) == owner&.owner_id.to_s
        found_in_hubspot = contact.present? && !(is_same_owner)
      rescue Hubspot::RequestError => eh
        Bugsnag.notify(eh)
      end
    end

    result = (!found_in_database && !found_in_hubspot)

    render json: result, status: :ok
  end

  # POST /clients
  def create
    @client.origin = "cartera"
    @client.branch = current_user.branch.name if current_user.branch.present?
    @client.main_phone = params.dig(:client, :client_main_phone)
    @client.optional_phone = params.dig(:client, :client_optional_phone)
    @client.source = AutomatedEmail.sources[:web]
    if @client.save
      add_additional(@client)
      add_referred_clients(@client)
      redirect_to @client, success: "Cliente creado correctamente."
    else
      flash[:error] = "No es posible crear el cliente con esos datos"
      render :new
    end
  end

  # PATCH/PUT /clients/1
  def update
    if params[:client].present?
      unless params.dig(:client, :client_main_phone).nil?
        params[:client][:main_phone] = params.dig(:client, :client_main_phone)
      end

      unless params.dig(:client, :client_optional_phone).nil?
        params[:client][:optional_phone] = params.dig(:client, :client_optional_phone)
      end
    end

    if @client.update(client_params)
      if @client.person == "physical"
        if PhysicalClient.where(client_id: @client.id).count > 0
          edit_additional(@client)
        else
          add_additional(@client)
        end
      else
        if MoralClient.where(client_id: @client.id).count > 0
          edit_additional(@client)
        else
          add_additional(@client)
        end
      end

      confirm_new_email(@client)

      flash[:alert] = "Cliente actualizado correctamente."
      redirect_to params[:folder].present? ? folder_path(params[:folder]) : @client
    else
      render :edit
    end
  end

  # DELETE /clients/1
  def destroy
    @client.destroy
    redirect_to clients_path, success: "Cliente eliminado correctamente."
  end

  # DELETE /clients/1/suppression
  def delete_suppression
    @client.delete_suppression if @client.suppresed_email?
    redirect_to client_path(@client), success: "Email actualizado correctamente"
  end

  def mass_reassign
    clients = Client.includes(:client_users).where(client_users: { user_id: mass_reassign_params[:source_user] })

    ActiveRecord::Base.transaction do
      clients.each do |client|
        unless client.client_users.where(user_id: mass_reassign_params[:target_user]).any?
          client_user = client.client_users.find_by(user_id: mass_reassign_params[:source_user], client_user_concept_id: mass_reassign_params[:client_user_concept_id])
          if client_user.present?
            client_user.update(user_id: mass_reassign_params[:target_user].to_i)
          end
        end
      end
    rescue StandardError => ex
      flash[:error] = "Reasignación fallida: #{ex.message}"
      Bugsnag.notify(ex)
    else
      flash[:success] = "La reasignación de clientes se completó con éxito."
    end

    redirect_to clients_path
  end

  def update_files
    folder = params.dig(:client, :folder)
    if @client.update(client_params)
      redirect_to folder.present? ? folder_path(folder) : @client, success: "Se agregaron correctamente los archivos del cliente."
    else
      render :edit
    end
  end

  def resend_email_confirmation
    begin
      return redirect_to clients_path, flash: { success: "El correo del cliente ya ha sido confirmado correctamente." } if @client.confirmed_email
      @client.send_email_confirmation_instructions
    rescue StandardError => ex
      Bugsnag.notify(ex)
      redirect_to clients_path, flash: { error: "Ocurrió un error al enviar el correo de confirmación." }
    end
    redirect_to clients_path, flash: { success: "Se ha enviado correctamente el correo de confirmación." }
  end

  def confirm_email
    begin
      @client = Client.find_by(id: params[:id])
      @client.update!(confirmed_email: true)

      user_client = @client.user_client

      if user_client.present?
        user_client.update!(email: @client.email)
      end
    rescue StandardError => ex
      Bugsnag.notify(ex)
      return render :confirm_email, locals: { error: "Ocurrió un error al confirmar el correo. Por favor, intente más tarde." }
    end
    render :confirm_email
  end

  def get_referred_clients
  end

  private

    def clients_logs_show
      @client_logs = ClientsLog.where(params[:client_id])
    end

    def mass_reassign_params
      params.require(:mass_reassign).permit(:source_user, :target_user, :client_user_concept_id)
    end

    def set_lead_sources
      @lead_sources ||= LeadSource.all.where(active: true)
    end

    def set_identification_types
      @identification_types ||= IdentificationType.all
    end

    def set_client_documents
      @client_documents = @client.documents.includes(:document_template).order("document_templates.order ASC")
    end

    def validate_email
      if Client.where(email: @client.email).size > 0
        flash[:error] = "Ya existe un cliente registrado con ese correo electrónico"
        redirect_to clients_path
      end
    end

    def get_translate(key)
      case key
      when "name"
        "Nombre"
      when "first_surname"
        "Apellido Paterno"
      when "second_surname"
        "Apellido Materno"
      when "main_phone"
        "Tel\u00E9fono Principal"
      when "optional_phone"
        "Tel\u00E9fono Opcional"
      when "email"
        "Correo"
      when "user_id"
        "Asesor"
      when "person"
        "Tipo de Persona"
      when "rfc"
        "RFC"
      when "place_birth"
        "País de Nacimiento"
      when "birthdate"
        "Fecha de Nacimiento"
      when "occupation"
        "Ocupación"
      when "civil_status"
        "Estado Civil"
      when "regime"
        "Regimen"
      when "state"
        "Estado"
      when "city"
        "Ciudad"
      when "country"
        "País"
      when "street"
        "Calle"
      when "house_number"
        "Número exterior"
      when "interior_number"
        "Número interior"
      when "colony"
        "Colonia"
      when "postal_code"
        "Código Postal"
      when "location"
        "Localidad"
      when "business_name"
        "Razón Social"
      when "rfc_company"
        "RFC de la Empresa"
      when "legal_rfc"
        "RFC del Apoderado Legal"
      when "legal_name"
        "Nombre del Apoderado Legal"
      when "notary_name"
        "Nombre de la Notaria"
      when "identification_type"
        "Tipo de Identificación"
      when "identification_number"
        "Número de Identificación"
      when "validity_identification"
        "Vigencia de Identificación"
      when "gender"
        "Género"
      when "curp_key"
        "CURP"
      else
        "Traducci\u00F3n no definida"
      end
    end

    def client_params
      params.require(:client).permit(:rid,
                                     :name,
                                     :first_surname,
                                     :second_surname,
                                     :main_phone,
                                     :optional_phone,
                                     :email,
                                     :user,
                                     :person,
                                     :curp,
                                     :official_identification,
                                     :address_proof,
                                     :constitutional_act,
                                     :fiscal_act,
                                     :gender,
                                     :additional,
                                     :lead_source_id,
                                     :birth_certificate,
                                     documents_attributes: [:id, file_versions_attributes: [ :id, :file ]])
    end

    def physical_client_params
      params.require(:client).require(:additional).permit(:identification_type_id,
                                                          :identification_number,
                                                          :validity_identification,
                                                          :rfc,
                                                          :place_birth,
                                                          :birthdate,
                                                          :occupation,
                                                          :nationality,
                                                          :civil_status,
                                                          :regime,
                                                          :state,
                                                          :city,
                                                          :country,
                                                          :street,
                                                          :house_number,
                                                          :interior_number,
                                                          :colony,
                                                          :postal_code,
                                                          :location,
                                                          :curp)
    end

    def moral_client_params
      params.require(:client).require(:additional).permit(:business_name,
                                                          :rfc_company,
                                                          :legal_rfc,
                                                          :legal_name,
                                                          :state,
                                                          :city,
                                                          :country,
                                                          :street,
                                                          :house_number,
                                                          :interior_number,
                                                          :colony,
                                                          :postal_code,
                                                          :location,
                                                          :curp,
                                                          :nationality,
                                                          :country_nationality,
                                                          :identification_type_id,
                                                          :identification_number,
                                                          :validity_identification,
                                                          :company_identification_type_id,
                                                          :company_identification_number,
                                                          :company_validity_identification,
                                                          :constitution_date,
                                                          :activity,
                                                          :birthdate,
                                                          :notary_name,
                                                          :notary_public_name,
                                                          :notary_public_number,
                                                          :commercial_electronic_folio_number,
                                                          :public_registry_state,
                                                          :public_registry_date)
    end

    def add_additional(client)
      return unless params[:client].present? && params[:client][:additional].present?
      unless is_not_empty(params[:client][:additional])
        return false
      end

      if params[:client][:additional][:colony] == "custom"
        params[:client][:additional][:colony] = params[:client][:additional][:colony_custom]
      end

      if client.person == "physical"
        @additional = PhysicalClient.create(physical_client_params)
        @additional.client = client
        @additional.save
      else
        @additional = MoralClient.create(moral_client_params)
        @additional.client = client
        @additional.save
      end
    end

    def edit_additional(client)
      return unless params.dig(:client, :additional).present? && is_not_empty(params.dig(:client, :additional))
      params[:client][:additional][:colony] = params.dig(:client, :additional, :colony_custom) if params.dig(:client, :additional, :colony) == "custom"

      if client.person == "physical"
        @additional = PhysicalClient.where(client_id: @client.id)
        @additional.update(physical_client_params)
      else
        @additional = MoralClient.where(client_id: @client.id)
        @additional.update(moral_client_params)
      end
    end

    def add_referred_clients(client)
      return unless params[:client].present? && params[:client][:referred_client].present?
      params[:client][:referred_client].each do |referred_client|
        ReferredClient.create!(client: client, referred_client_id: referred_client)
      end
    end

    def is_not_empty(additional)
      additional.each do |param|
        if param[1] != ""
          return true
        end
      end

      false
    end

    def translate_gender(gender)
      gender == "female" ? "Femenino" : "Masculino"
    end

    def sort_column
      if request.path == clients_path
        if Client.column_names.include?(params[:sort]) || ["client_user_created"].include?(params[:sort])
          return "users.first_name" if params[:sort] == "user_id"
          return "client_users.created_at" if params[:sort] == "client_user_created"
          params[:sort]
        else
          "name"
        end
      else
        if Folder.column_names.include?(params[:sort]) || ["project_id", "phase_id", "stage_id"].include?(params[:sort])
          return "users.first_name" if params[:sort] == "user_id"
          return "clients.name" if params[:sort] == "client_id"
          return "lots.name" if params[:sort] == "lot_id"
          return "projects.name" if params[:sort] == "project_id"
          return "phases.name" if params[:sort] == "phase_id"
          return "stages.name" if params[:sort] == "stage_id"
          params[:sort]
        else
          "created_at"
        end
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def verify_access
      if @client.present? && current_user.structure.present? && cannot?(:see_all, Client)
        raise CanCan::AccessDenied unless current_user.structure.subtree.pluck(:user_id).include?(@client.sales_executive&.id)
      end
    end

    def client_selection
      @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default

      if can?(:see_all, Client)
        @clients = Client.all
      elsif current_user.structure.present?
        client_ids = ClientUser.where(user_id: current_user.structure.subtree.pluck(:user_id)).pluck(:client_id)
        @clients = Client.where(id: client_ids)
        @sellers = User.can_reserve.where(id: current_user.structure.subtree.pluck(:user_id), is_active: true).order(created_at: :desc)
      else
        client_ids = ClientUser.where(user_id: current_user.id).pluck(:client_id)
        @clients = Client.where(id: client_ids)
      end
      @sellers ||= User.can_reserve.active.order(created_at: :desc)
    end

    def set_client_user_concepts
      @client_user_concepts = ClientUserConcept.all
    end

    def confirm_new_email(client)
      if client.saved_change_to_email?
        client.update(confirmed_email: false)
        client.send_email_confirmation_instructions
      end
    end
end
