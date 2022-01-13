# frozen_string_literal: true

require_relative "../../app/lib/map"

class PhasesController < ApplicationController
  include QuotationsHelper, EntityNamesConcern
  load_and_authorize_resource :project
  load_and_authorize_resource :phase, through: :project
  before_action :set_project_entity_names_by_project

  # GET /stages/new
  def new
  end

  # GET /stages/1/edit
  def edit
  end

  # POST /stages
  def create
    if @phase.save
      redirect_to project_path(@project), success: "#{@stage_singular} creada correctamente."
    else
      @phase.slug = nil if @phase.errors.added?(:slug, :taken, value: @phase.slug)
      render :new
    end
  end

  # PATCH/PUT /stages/1
  def update
    if blueprint_present?
      if params[:phase][:blueprint][:file].present?
        add_blueprint
      else
        edit_blueprint
      end
    end

    if @phase.update(phase_params)
      redirect_to project_path(@project), success: "#{@stage_singular} actualizada correctamente."
    else
      @phase.slug = nil if @phase.errors.added?(:slug, :taken, value: @phase.slug)
      render :edit
    end
  end

  # DELETE /stages/1
  def destroy
    @phase.destroy
    redirect_to project_path(@project), success: "#{@stage_singular} eliminada correctamente."
  end

  private

    def phase_params
      params.require(:phase).permit(:name, :slug, :quantity, :area, :price, :start_date, :reference, :annex)
    end

    def blueprint_params
      params.require(:phase).require(:blueprint).permit(:background)
    end

    def add_blueprint
      @map = Map.new(retrieve_svg_file.path)

      @blueprint = Blueprint.create(blueprint_params)
      @blueprint.svg_file.purge
      @blueprint.svg_file.attach(retrieve_svg_file)
      @blueprint.styles = @map.get_styles
      @blueprint.view_box = @map.read_view_box
      @blueprint.style = @map.read_style
      @phase.blueprint = @blueprint

      @blueprint_stages = @map.read_reference_data(BlueprintStage)

      @blueprint.blueprint_stages = @blueprint_stages
    end

    def edit_blueprint
      @blueprint = Blueprint.where(level_type: "Phase", level_id: @phase.id)
      @blueprint.update(blueprint_params)
    end

    def retrieve_svg_file
      params[:phase][:blueprint][:file]
    end

    def blueprint_present?
      params[:phase].present? && params[:phase][:blueprint].present?
    end
end
