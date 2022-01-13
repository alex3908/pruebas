# frozen_string_literal: true

class FolderUsersController < ApplicationController
  include CommissionsHelper, FoldersHelper, EntityNamesConcern
  before_action :set_user, only: [:create]
  before_action :set_folder, except: [:new, :export_xlsx]
  before_action :set_project_entity_names_by_folder, only: [:show]
  before_action :set_folder_user, only: [:edit, :update, :destroy]

  def new
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def create
    raise CanCan::AccessDenied if !@step_role&.can_add_folder_user? && cannot?(:create, FolderUser) && cannot?(:create_only_hidden, FolderUser)

    exist_folder_user = @folder.users.include?(@user)

    unless exist_folder_user
      folder_user = FolderUser.new(folder_users_params)
      folder_user_concept = FolderUserConcept.find(folder_user.folder_user_concept_id)
      folder_user.folder = @folder
      folder_user.percentage = folder_user_concept.commission
      folder_user.visible = folder_user_concept.visible
      folder_user.role = folder_user.user.try(:role)
      @created_folder_user = folder_user.save
    end

    respond_to do |format|
      format.js { render :create, locals: { exist_folder_user: exist_folder_user } }
    end
  end

  def update
    raise CanCan::AccessDenied if !@step_role&.can_edit_folder_user? && cannot?(:update, FolderUser) && cannot?(:update_only_hidden, FolderUser)

    exist_folder_user = @folder.folder_users.where("id != ? AND user_id = ?", @folder_user.id, folder_users_params[:user_id]).first
    unless exist_folder_user
      @updated_folder_user = @folder_user.update(folder_users_params)
    end

    respond_to do |format|
      format.js { render :update, locals: { exist_folder_user: exist_folder_user } }
    end
  end

  def export_xlsx
    folder_users = FolderUser.set_params(params, "folder_users.created_at", "desc")

    job_status = JobStatus.create!(name: "Reporte de responsables - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = FolderUsersReportJob.perform_later(job_status, folder_users.pluck(:id))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def destroy
    raise CanCan::AccessDenied if !@step_role&.can_remove_folder_user? && cannot?(:destroy, FolderUser) && cannot?(:destroy_only_hidden, FolderUser)

    if @folder.users.length > 1
      if @folder_user.destroy
        redirect_to folder_path(@folder), success: "Se ha desligado a #{@folder_user.user.label} de este expediente."
      else
        redirect_to folder_path(@folder), error: "Hubo un error al intentar remover el responsable."
      end
    else
      redirect_to folder_path(@folder), warning: "El expediente necesita al menos un responsable."
    end
  end

  private

    def set_folder_user
      @folder_user = FolderUser.find_by!(id: params[:id])
    end

    def set_user
      @user = User.find_by(id: folder_users_params[:user_id])
    end

    def set_folder
      @folder = Folder.find_by!(id: params[:folder_id])
      @step_role = @folder&.step&.step_roles&.find_by(role: current_user.role)
    end

    def folder_users_params
      params.require(:folder_user).permit(:user_id, :percentage, :concept, :folder_user_concept_id, :visible)
    end
end
