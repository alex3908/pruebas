# frozen_string_literal: true

class ClientUsersController < ApplicationController
  load_and_authorize_resource
  before_action :set_client_users, only: [:index]

  def index
  end

  def show
  end

  def create
    if @client_user.save
      clients_logs("Agregado", @client_user.client_id, @client_user.client_user_concept_id, @client_user.user_id)
    end
    render :response, status: :ok
  end

  def update
    if @client_user.update(client_user_params)
      clients_logs("actualizado", @client_user.client_id, @client_user.client_user_concept_id, @client_user.user_id)
    end
    render :response, status: :ok
  end


  def destroy
    if clients_logs("Eliminado", @client_user.client_id, @client_user.client_user_concept_id, @client_user.user_id)
      @client_user.destroy
    end
    render :response, status: :ok
  end

  def get_concepts
  end

  def list_users_role
    client_user_concept = ClientUserConcept.find_by_id(params[:id])
    @users = User.includes(:role).where(role: client_user_concept.roles)
    render json: { users: @users.map { | user | { id: user.id, text: user.label } } }
  end

  private

    def clients_logs(action, client_id, client_user_concept_id, user_id)
      ClientsLog.create(action: action, client_id: client_id, client_user_concept_id: client_user_concept_id, client_users_id: user_id, moved_at: DateTime.now)
    end
    def set_client_users
      client = Client.find(params[:client_id])
      @client_users = client.client_users
    end

    def client_user_params
      params.require(:client_user).permit(:user_id, :client_user_concept_id, :client_id)
    end
end
