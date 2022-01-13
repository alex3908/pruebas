# frozen_string_literal: true

class SettingsController < ApplicationController
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction

  def index
    @settings = @settings.permitted(can?(:view_hidden, Setting)).set_params(params, sort_column, sort_direction).paginate(page: params[:page], per_page: @per_page)
  end

  def show
  end

  def new
    @setting = Setting.new
  end

  def edit
  end

  def create
    if @setting.save
      redirect_to settings_path, success: "Configuración creada correctamente."
    else
      render :new
    end
  end

  def update
    if @setting.update(setting_params)
      redirect_to settings_path, success: "Configuración editada correctamente."
    else
      render :edit
    end
  end

  def destroy
    @setting.destroy
    redirect_to settings_path, success: "Configuración eliminada correctamente."
  end

  private

    def setting_params
      params.require(:setting).permit(:key, :data_type, :label, :value, :concept, :hidden)
    end

    def sort_column
      Setting.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
