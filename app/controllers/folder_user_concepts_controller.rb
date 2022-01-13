# frozen_string_literal: true

class FolderUserConceptsController < ApplicationController
  load_and_authorize_resource
  before_action :set_roles, only: [:new, :create, :edit, :update]

  def index
    @folder_user_concepts = @folder_user_concepts.paginate(page: params[:page], per_page: @per_page)
  end

  def new
  end

  def edit
  end

  def show
  end

  def users
    @folder_user_concept = FolderUserConcept.find_by(id: params[:folder_user_concept_id])
    respond_to do |format|
      format.js { }
    end
  end

  def create
    respond_to do |format|
      if @folder_user_concept.save
        format.html { redirect_to folder_user_concepts_path, notice: "El concepto de responsable ha sido creado exitosamente." }
      else
        format.html { redirect_to folder_user_concepts_path, alert: @folder_user_concept.errors.values.join(",") }
      end
    end
  end

  def update
    respond_to do |format|
      if @folder_user_concept.update(folder_user_concept_params)
        format.html { redirect_to folder_user_concepts_path, notice: "El concepto de responsable ha sido actualizado exitosamente.." }
      else
        format.html { redirect_to folder_user_concepts_path, alert: @folder_user_concept.errors.values.join(",") }
      end
    end
  end

  def destroy
    if @folder_user_concept.destroy
      respond_to do |format|
        format.html { redirect_to folder_user_concepts_url, notice: "El concepto de responsable fue eliminado correctamente." }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html { redirect_to folder_user_concepts_url, alert: @folder_user_concept.errors.messages.values.join(",") }
        format.json { head :no_content }
      end
    end
  end

  private

    def folder_user_concept_params
      params.require(:folder_user_concept).permit(:name, :commission, :visible, role_ids: [])
    end

    def set_roles
      @roles = Role.all
    end
end
