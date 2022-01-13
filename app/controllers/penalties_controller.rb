# frozen_string_literal: true

class PenaltiesController < ApplicationController
  load_and_authorize_resource
  before_action :set_folder
  before_action :set_installment

  def new
  end

  def create
    amount = @penalty.amount
    attributes = {
      installment_id: @installment.id,
      user: current_user,
      amount: amount
    }

    if @installment.penalty.nil?
      Penalty.create!(attributes)
      redirect_to folder_installments_path(@folder), success: "Se agregó una penalización al número de pago #{@installment.number} de #{@installment.concept_label}"
    else
      @installment.penalty.update_attributes!(active: true, amount: amount)
      redirect_to folder_installments_path(@folder), success: "Se agregó una penalización al número de pago #{@installment.number} de #{@installment.concept_label}"
    end

  rescue StandardError
    redirect_to folder_installments_path(@folder), error: "Hubo un error al intentar agregar una penalización al número de pago #{@installment.number} de #{@installment.concept_label}"
  end

  def update
    @installment.penalty.update_attributes!(active: false, canceled_by: current_user)
    redirect_to folder_installments_path(@folder), success: "Se removió la penalización al número de pago #{@installment.number} de #{@installment.concept_label}"

  rescue StandardError
    redirect_to folder_installments_path(@folder), error: "Hubo un error al intentar remover la penalización al número de pago #{@installment.number} de #{@installment.concept_label}"
  end

  private
    def set_folder
      @folder = Folder.find_by(id: params[:folder_id])
    end

    def set_installment
      if params[:format].present?
        @installment = Installment.find_or_create_by(id: params[:format])
      else
        @installment = Installment.find_or_create_by(number: params[:number],
          concept: params[:concept],
          folder: @folder,
          date: params[:date],
          down_payment: params[:down_payment].to_f.round(2),
          total: params[:payment].to_f.round(2),
          capital: params[:capital].present? ? params[:capital].to_f.round(2) : nil,
          interest: params[:interest].present? ? params[:interest].to_f.round(2) : nil,
          debt: params[:amount].present? ? params[:amount].to_f : nil)
      end
    end
    def penalty_params
      params.require(:penalty).permit(:amount)
    end
end
