# frozen_string_literal: true

class BlueprintsController < ApplicationController
  before_action :set_blueprint, only: [:deallocate]
  load_and_authorize_resource only: [:deallocate]

  def deallocate
    respond_to do |format|
      if @blueprint.blueprint_lots.update_all("lot_id = NULL")
        format.html { redirect_to edit_project_phase_stage_path(@project, @phase, @stage), notice: "Se han desasignado todos los #{@lot_plural}." }
        format.json { render status: :ok }
      else
        format.html { redirect_to edit_project_phase_stage_path(@project, @phase, @stage), notice: "Hubo un error al intentar hacer el cambio." }
        format.json { render json: @blueprint.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blueprint
      @project = Project.find(params[:project_id])
      @phase = Phase.find(params[:phase_id])
      @stage = Stage.find(params[:stage_id])
      @blueprint = Blueprint.includes(:blueprint_lots).find(params[:id])
    end
end
