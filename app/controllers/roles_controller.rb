# frozen_string_literal: true

class RolesController < ApplicationController
  include PermissionsHelper

  load_and_authorize_resource

  before_action :set_role, only: [:show, :edit, :update, :destroy, :verify_reserve_status]
  before_action :set_permissions, only: [:show, :new, :create, :edit, :update]

  def index
    @roles = @roles.permitted(can?(:view_hidden, Role)).order(:name)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @role.save
      redirect_to @role, success: "Rol creado correctamente."
    else
      render :new
    end
  end

  def update
    if @role.update(role_params)
      redirect_to @role, success: "Rol editado correctamente."
    else
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @role.users.empty?
        @role.destroy
        format.html { redirect_to roles_path(page: params[:page], per_page: params[:per_page]), notice: "Rol eliminado correctamente" }
        format.json { head :no_content }
      else
        format.html { redirect_to roles_path(page: params[:page], per_page: params[:per_page]), notice: "No es posible eliminar ese rol, cuenta con usuarios." }
        format.json { status :unprocessable_entity }
      end
    end
  end

  def classifiers
    respond_to do |f|
      f.json { render json: { classifiers: @role.classifiers }, status: :ok }
    end
  end

  def verify_reserve_status
    can_reserve = @role.permissions.find_by(subject_class: ":quote", action: "reserve").present?

    respond_to do |f|
      f.json { render json: can_reserve, status: :ok }
    end
  end


  private

    def role_params
      params
      .require(:role)
      .permit(
        :name,
        :hidden,
        permission_ids: [],
        quote_role_attributes: [
          :min_months_deferred_down_payment,
          :max_months_deferred_down_payment,
          :min_days_first_monthly_payment,
          :max_days_first_monthly_payment,
          :min_days_second_monthly_payment,
          :max_days_second_monthly_payment
        ]
      )
    end

    def set_role
      @role = Role.permitted(can?(:view_hidden, Role)).includes(:permissions).find(params[:id])
    end

    def set_permissions
      @permissions = Permission.permitted(can?(:view_hidden, Permission)).order(:subject_class, :action).group_by(&:subject_class)
    end
end
