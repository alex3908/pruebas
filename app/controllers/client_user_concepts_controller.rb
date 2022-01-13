# frozen_string_literal: true

class ClientUserConceptsController < ApplicationController
  load_and_authorize_resource
  before_action :set_roles, only: [:new, :edit]

  def index
    @client_user_concepts = @client_user_concepts.paginate(page: params[:page], per_page: @per_page)
    respond_to do |format|
      format.html
      format.json
    end
  end

  def new
  end

  def edit
  end

  def create
    respond_to do |format|
      if @client_user_concept.save
        format.html { redirect_to client_user_concepts_path, notice: "El concepto de cliente ha sido creado exitosamente." }
      else
        format.html { redirect_to client_user_concepts_path, alert: @client_user_concept.errors.values.join(",") }
      end
    end
  end

  def update
    respond_to do |format|
      if @client_user_concept.update(client_user_concept_params)
        format.html { redirect_to client_user_concepts_path, notice: "El concepto de cliente ha sido actualizado exitosamente.." }
      else
        format.html { redirect_to client_user_concepts_path, alert: @client_user_concept.errors.values.join(",") }
      end
    end
  end

  def destroy
    if @client_user_concept.destroy
      respond_to do |format|
          format.html { redirect_to client_user_concepts_url, notice: "El concepto de cliente fue eliminado correctamente." }
        end
    else
      respond_to do |format|
          format.html { redirect_to client_user_concepts_url, alert: @client_user_concept.errors.messages.values.join(",") }
        end
    end
  end

  private

    def client_user_concept_params
      params.require(:client_user_concept).permit(:name, :max_users, role_ids: [])
    end

    def set_roles
      @roles = Role.all
    end
end
