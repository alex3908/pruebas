# frozen_string_literal: true

class AdditionalConceptsController < ApplicationController
  load_and_authorize_resource
  helper_method :sort_column, :sort_direction
  before_action :set_stage, only: %i[activate]

  def index
    @additional_concepts = @additional_concepts.paginate(page: params[:page], per_page: @per_page)
  end

  def new
    @additional_concept = AdditionalConcept.new
  end

  def edit
  end

  def show
    @stages = Stage.paginate(page: params[:page], per_page: @per_page).includes(phase: :project).set_params(params, sort_column, sort_direction)
    @projects = Project.includes(phases: :stages).order(id: :asc)
    @filter_path = additional_concept_path(@additional_concept)
  end

  def create
    respond_to do |format|
      if @additional_concept.save!
        format.html { redirect_to additional_concepts_path, notice: "El servicio adicional ha sido creado exitosamente." }
        format.json { render :show, status: :created, location: @additional_concept }
      else
        format.html { render :new }
        format.json { render json: @additional_concept.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @additional_concept.update!(additional_concept_params)
        format.html { redirect_to additional_concepts_path, notice: "El servicio adicional ha sido actualizado exitosamente." }
        format.json { render :show, status: :created, location: @additional_concept }
      else
        format.html { render :new }
        format.json { render json: @additional_concept.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @additional_concept.destroy
    respond_to do |format|
      format.html { redirect_to additional_concepts_path, notice: "El servicio adicional ha sido eliminado exitosamente." }
      format.json { head :no_content }
    end
  end

  def change_status
    if !@additional_concept.stages.any?
      status = @additional_concept.active ? "desactivado" : "activado"
      @additional_concept.toggle!(:active)
      redirect_to additional_concepts_path, flash: { success: "El servicio adicional '#{@additional_concept.name}' fue #{status}." }
    else
      redirect_to additional_concepts_path, flash: { warning: "El servicio adicional '#{@additional_concept.name}' no se puede desactivar porque está asignado a #{@additional_concept.stages.count} etapa(s)." }
    end
  end

  def activate
    raise CanCan::AccessDenied.new("No tienes permisos para activar este servicio") unless can?(:change_status, AdditionalConcept)
    status = params[:status] == "true"

    if status && !@stage.has_additional_concept(@additional_concept)
      @stage.additional_concepts << @additional_concept
    elsif !status && @stage.has_additional_concept(@additional_concept)
      @stage.additional_concepts.delete(@additional_concept)
    end

    respond_to do |format|
      if @stage.save!
        format.html { redirect_to additional_concept_path(@additional_concept), notice: "El servicio adicional ha sido #{ status ? "activado" : "desactivado"} exitosamente." }
        format.json { render json: @additional_concept, status: :ok, location: @additional_concept }
      else
        format.html { redirect_to additional_concept_path(@additional_concept), flash: { danger: "Hubo un error al intentar guardar la información." } }
        format.json { render json: @additional_concept.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    def additional_concept_params
      params.require(:additional_concept).permit(:name, :description, :amount_type, :amount, :enterprise_id)
    end

    def set_stage
      @stage = Stage.find(params[:stage])
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def sort_column
      AdditionalConcept.column_names.include?(params[:sort]) ? params[:sort] : "stages.id"
    end
end
