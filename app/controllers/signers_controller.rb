# frozen_string_literal: true

class SignersController < ApplicationController
  include SignersHelper
  load_and_authorize_resource

  helper_method :sort_column, :sort_direction

  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @filter_path = signers_path
    @signers = Signer.set_params(params, sort_column, sort_direction)
  end

  def edit
  end

  def new
  end

  def create
    if @signer.save(signer_params)
      redirect_to signers_path, flash: { success: "Firmante creado correctamente." }
    else
      render :new
    end
  end

  def update
    if @signer.update(signer_params)
      redirect_to signers_path, flash: { success: "Firmante modificado correctamente." }
    else
      render :edit
    end
  end

  def destroy
    if @signer.contracts.present?
      redirect_to signers_path, flash: { error: "No se pueden eliminar firmantes ligados a algún contrato." }
    else
      @signer.destroy
      redirect_to signers_url, success: "Firmante eliminado correctamente."
    end
  end

  private

    def signer_params
      params.require(:signer).permit(:name, :first_surname, :second_surname, :definition, :role, :company, :email, :phone, :is_an_observer)
    end

    def sort_column
      if Signer.column_names.include?(params[:sort])
        params[:sort]
      else
        "name"
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
