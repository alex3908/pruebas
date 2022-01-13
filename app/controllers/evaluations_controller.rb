# frozen_string_literal: true

class EvaluationsController < ApplicationController
  include EvaluationsHelper
  load_and_authorize_resource
  helper_method :translate_evaluation_type

  before_action :set_steps, only: [:new, :create, :edit, :update]

  def index
    @evaluations = @evaluations.order(created_at: :asc)
    @evaluations_approve = @evaluations.where(question_type: :approve)
    @evaluations_reject = @evaluations.where(question_type: :reject)
    @evaluations_cancel = @evaluations.where(question_type: :cancel)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @evaluation.save
      redirect_to evaluations_path, success: "Pregunta creada correctamente."
    else
      render :new
    end
  end

  def update
    if @evaluation.update(evaluation_params)
      redirect_to evaluations_path, success: "Pregunta editada correctamente."
    else
      render :edit
    end
  end

  def destroy
    if @evaluation.evaluation_folders.size == 0 && @evaluation.destroy
      redirect_to evaluations_url, success: "Pregunta eliminada correctamente."
    elsif @evaluation.evaluation_folders.size != 0
      redirect_to evaluations_url, error: "Esta pregunta ya ha sido contestada por algún expediente y por ende no se puede eliminar."
    else
      redirect_to evaluations_url, error: "Hubo un problema elminando la pregunta."
    end
  end

  def change_status
    @evaluation.toggle!(:active)
  end

  private

    def set_steps
      @steps = Step.all
    end

    def evaluation_params
      params.require(:evaluation)
            .permit(
              :question,
              :question_type,
              :active,
              step_ids: []
            )
    end
end
