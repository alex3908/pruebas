# frozen_string_literal: true

class PermissionsController < ApplicationController
  load_and_authorize_resource
  include RolesHelper

  def index
    @classes = permission_group_name_translated
    @permissions = @permissions.permitted(can?(:view_hidden, Permission)).search(params).paginate(page: params[:page], per_page: @per_page).order("id DESC")
  end

  def show
  end

  def new
    @classes = permission_group_name_translated
  end

  def edit
    @classes = permission_group_name_translated
  end

  def create
    if @permission.save
      redirect_to permissions_path, success: "Permiso creado correctamente"
    else
      render :new
    end
  end

  def update
    if @permission.update(permission_params)
      redirect_to permissions_path, success: "Permiso editado correctamente"
    else
      render :new
    end
  end

  def destroy
    @permission.destroy
    redirect_to permissions_path, success: "Permiso eliminado correctamente"
  end

  private

    def permission_params
      params.require(:permission).permit(:name, :subject_class, :action, :description, :hidden)
    end
end
