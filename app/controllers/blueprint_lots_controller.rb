# frozen_string_literal: true

class BlueprintLotsController < ApplicationController
  before_action :set_blueprint_lot, only: [:update]
  load_and_authorize_resource only: [:update]

  def update
    respond_to do |format|
      if @blueprint_lot.update(blueprint_lot_params)
        format.html { redirect_to project_phase_stage_blueprint_blueprint_lots_url(@project, @phase, @stage, @blueprint), notice: "#{@lot_singular} actualizado correctamente." }
        format.json { render json: @blueprint_lot.to_json(include: [:lot]) }
      else
        format.html { render :edit }
        format.json { render json: @blueprint_lot.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_blueprint_lot
      @project = Project.find(params[:project_id])
      @phase = Phase.find(params[:phase_id])
      @stage = Stage.find(params[:stage_id])
      @blueprint = Blueprint.find(params[:blueprint_id])
      @blueprint_lot = BlueprintLot.find(params[:id])
    end

    def blueprint_lot_params
      params.require(:blueprint_lot).permit(:lot_id)
    end
end
