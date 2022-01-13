# frozen_string_literal: true

class BlueprintStagesController < ApplicationController
  include EntityNamesConcern
  before_action :set_blueprint_stage, :set_project_entity_names_by_project
  load_and_authorize_resource

  def update
    respond_to do |format|
      if @blueprint_stage.update(blueprint_stage_params)
        format.html { redirect_to project_phase_stage_blueprint_blueprint_stages_url(@project, @phase, @blueprint), notice: "#{@stage_singular} actualizada correctamente." }
        format.json { render json: @blueprint_stage.to_json(include: [:stage]) }
      else
        format.html { render :edit }
        format.json { render json: @blueprint_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_blueprint_stage
      @project = Project.find(params[:project_id])
      @phase = Phase.find(params[:phase_id])
      @blueprint = Blueprint.find(params[:blueprint_id])
      @blueprint_lot = BlueprintStage.find(params[:id])
    end

    def blueprint_stage_params
      params.require(:blueprint_stage).permit(:stage_id)
    end
end
