# frozen_string_literal: true

require "net/http"
require "pdfkit"

class ProjectsController < ApplicationController
  include EntityNamesConcern
  load_and_authorize_resource
  before_action :set_project, only: [:index, :show, :edit, :update, :destroy, :level_price_params]
  before_action :set_project_entity_names_by_project, only: [:show, :edit]
  before_action :verify_access, except: [:new, :create]
  helper_method :encode_base_64

  # GET /projects
  def index
    @per_page = params[:per_page].to_i < 1 ? 12 : params[:per_page] || 12
    if can?(:create, Project)
      @projects = Project.all.order(order: :asc).includes(phases: :stages)
    else
      @project_users = ProjectUser.where(user_id: current_user.id)
      @projects = Project.where(project_users: @project_users, active: true).order(order: :asc).includes(phases: :stages)
    end

    respond_to do |format|
      format.html {
        @projects = @projects.paginate(page: params[:page], per_page: @per_page)
        render :index
      }
    end
  end

  # GET /projects/1
  def show
    @phases = Phase.where(project_id: @project.id).order(order: :asc)
    if cannot?(:create, Phase) && cannot?(:create, Stage)
      stage_users = StageUser.where(user_id: current_user.id)
      @stages = Stage.includes(:stage_users).where(phase_id: @phases, stage_users: stage_users)
      @phases = Phase.where(id: @stages.pluck(:phase_id))
    end
    @project_users = ProjectUser.where(project_id: @project.id) # Todo: Review if is used
    @stages_names = @project.phases.map { |phase| phase.stages }.flatten(1).map { |stage| [stage.full_name, stage.id] }
  end

  # GET /projects/new
  def new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  def create
    if @project.save
      redirect_to @project, success: "#{@project.project_entity_name} creado correctamente."
    else
      @project.slug = nil if @project.errors.added?(:slug, :taken, value: @project.slug)
      render :new
    end
  end

  # PATCH/PUT /projects/1
  def update
    if @project.update(project_params)
      redirect_to @project, success: "#{@project.project_entity_name} editado correctamente."
    else
      @project.slug = nil if @project.errors.added?(:slug, :taken, value: @project.slug)
      render :edit
    end
  end

  # DELETE /projects/1
  def destroy
    @project.destroy
    redirect_to projects_path, success: "#{@project.project_entity_name} eliminado correctamente."
  end

  def status
    @project.toggle!(:active)
  end

  def remove_file
    project = Project.find(params[:project_id])
    attachment = ActiveStorage::Attachment.find(params[:file_id])
    attachment.purge
    redirect_to project_path(project), flash: { success: "Se elimino correctamente el archivo." }
  rescue Exception
    redirect_to project_path(project), flash: { error: "No se pudo eliminar el archivo." }
  end

  def export
    job_status = JobStatus.create!(name: "Reporte de proyectos - #{Time.zone.now.strftime("%m/%d/%Y %I:%M%p ")}", user: current_user, status: "pending")
    job = ProjectsExportJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def import
    job_status = JobStatus.create!(
      name: "Importación de proyectos - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :up_and_downloadable,
      file: params[:file]
    )

    job = ProjectsImportJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def export_units
    stages = Stage.includes(phase: :project).search(params).pluck(:id)
    job_status = JobStatus.create!(name: "Reporte de unidades - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = UnitsReportJob.perform_later(job_status, stages)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def level_price
    if level_price_params[:all_stages] == true.to_s
      stage_ids = @project.stages.map(&:id)
    else
      stage_ids = level_price_params[:stage_ids].reject(&:blank?)
    end

    job_status = PriceLevelerJobStatus.create!(
      date: level_price_params[:date],
      user: current_user,
      stage_ids: stage_ids,
      price: level_price_params[:price]
    )

    job = PriceLevelerJob.set(wait_until: Time.zone.parse(level_price_params[:date]))
      .perform_later(job_status, stage_ids, level_price_params[:price])

    if job_status.update(job_id: job.provider_job_id)
      flash[:success] = "La nivelación se ha programado con éxito."
    else
      flash[:error] = "Ocurrió un error al programar la nivelación."
    end

    redirect_to projects_path
  end

  private

    def project_params
      params.require(:project)
        .permit(
          :rid,
          :name,
          :currency,
          :email,
          :phone,
          :macroplane,
          :logo,
          :background,
          :quotation,
          :reference,
          :project_entity_name,
          :phase_entity_name,
          :stage_entity_name,
          :lot_entity_name,
          :color,
          :subtitle_color,
          :divider_color,
          :font_color,
          :facebook,
          :instagram,
          :website,
          :slug,
          :show_amortization_table,
          :show_rate,
          :show_price,
          :show_bank_account,
          :show_final_price,
          :show_payment_dates,
          templates: [])
    end

    def level_price_params
      params.require(:level_price)
      .permit(
        :price,
        :date,
        :all_stages,
        stage_ids: [])
    end

    def set_project
      @per_page = params[:per_page].to_i < 1 ? 12 : params[:per_page] || 12

      if can?(:seller, Folder)
        @project_users = ProjectUser.accessible_by(current_ability)
        @projects = Project.where(project_users: @project_users).order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
      else
        @projects = Project.order(created_at: :desc).paginate(page: params[:page], per_page: @per_page)
      end

      if params[:id].present?
        @project = Project.find(params[:id])
      end
    end

    def encode_base_64(element)
      Base64.encode64(element.to_s)
    end

    def verify_access
      if @project.present?
        if can?(:create, Project)
          projects = Project.all.order(order: :asc).includes(phases: :stages)
        else
          project_users = ProjectUser.where(user_id: current_user.id)
          projects = Project.where(project_users: project_users, active: true).order(order: :asc).includes(phases: :stages)
        end

        raise CanCan::AccessDenied unless projects.pluck(:id).include?(@project.id)
      end
    end
end
