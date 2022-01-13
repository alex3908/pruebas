# frozen_string_literal: true

class Api::V1::ClientsController < API::V1::BaseController
  load_and_authorize_resource :client
  # GET
  def index
    if can?(:see_all, Client)
      @clients = Client.all
    elsif current_user.structure.present?
      @clients = @clients.where(user: current_user.structure.subtree.pluck(:user_id))
    elsif can?(:reserve, :quote)
      @clients = @clients.where(user: current_user)
    end

    @clients = @clients.search(params).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def create
    ActiveRecord::Base.transaction do
      @client = Client.new(client_params)
      @client.user_id = current_user.id
      @client.origin = "cartera"
      @client.branch = current_user.branch.name if current_user.branch.present?
      @client.client_users.create(user: current_user, client_user_concept: @client.class.default_client_concept)
      @client.source = AutomatedEmail.sources[:api]
      @client.save!
      add_additional(@client)
      render json: { message: "Cliente Guardado correctamente" }, status: :ok
    end
  rescue => exception
    render json: { message: exception.message }, status: :ok
  end

  def upload_files
    @client.update(upload_params)
  rescue
    render json: { message: "Ocurrió un error al guardar el archivo" }, status: :unprocessable_entity
  end


  private

    def add_additional(client)
      return unless  params[:client][:additional].present?
      if client.person == Client::PHYSICAL
        @additional = PhysicalClient.create(physical_client_params)
      else
        @additional = MoralClient.create(moral_client_params)
      end
      @additional.client = client
      @additional.save!
    end

    def upload_params
      params.permit(:curp,
                    :official_identification,
                    :address_proof,
                    :constitutional_act,
                    :fiscal_act)
    end

    def client_params
      params.require(:client).permit(:name,
                                     :first_surname,
                                     :second_surname,
                                     :email,
                                     :main_phone,
                                     :optional_phone,
                                     :gender,
                                     :person,
                                     :additional)
    end

    def physical_client_params
      params.require(:client).require(:additional).permit(:identification_type,
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
                                                          :notary_name,
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
                                                          :identification_type,
                                                          :identification_number,
                                                          :validity_identification,
                                                          :company_identification_type,
                                                          :company_identification_number,
                                                          :company_validity_identification,
                                                          :constitution_date,
                                                          :activity,
                                                          :birthdate)
    end
end
