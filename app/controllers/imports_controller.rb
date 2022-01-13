# frozen_string_literal: true

class ImportsController < ApplicationController
  def index
  end

  def select_projects
    @select_project = Project.all
    render json: @select_project.pluck(:id, :name)
  end

  def phases
    if params[:id].present?
      @phases = Phase.where(project_id: params[:id])
    else
      @phases = Phase.all
    end
    render json: @phases.pluck(:id, :name)
  end

  def stages
    if params[:id].present?
      @stages = Stage.where(phase_id: params[:id])
    else
      @stages = Stage.all
    end
    render json: @stages.pluck(:id, :name)
  end

  def import_amortization_table
    job_status = JobStatus.create!(
      name: "Importación de tabla de amortización - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: "uploadable",
      file: params[:file]
    )

    job = ImportInstallmentsJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def template_amortization_table
    job_status = JobStatus.create!(name: "Plantilla de tabla de amortización - #{Time.zone.now.strftime("%m/%d/%Y %I:%M%p ")}", user: current_user, status: "pending")
    job = ExportAmortizationTemplateJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def import_cash_flow
    job_status = JobStatus.create!(
      name: "Creación de flujos de caja - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :uploadable,
      file: params[:file]
    )

    job = CashFlowImportJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def template_cash_flow
    job_status = JobStatus.create!(name: "Plantilla de flujos de caja - #{Time.zone.now.strftime("%m/%d/%Y %I:%M%p ")}", user: current_user, status: "pending")
    job = ExportCashFlowTemplateJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def template_client_user
    job_status = JobStatus.create!(name: "Plantilla de responsables de clientes - #{Time.zone.now.strftime("%m/%d/%Y %I:%M%p ")}", user: current_user, status: "pending")
    job = ExportClientUserTemplateJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def download_import_template
    if can?(:import, Client)
      send_file(Rails.root.join("public", "plantilla_clientes.xlsx"))
    end
  end

  def import_client
    job_status = JobStatus.create!(
      name: "Importación de clientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: "uploadable",
      file: params[:file]
    )

    job = ClientImportJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def download_corrections
    send_file "public/formato_correcciones.xlsx", type: "application/xls", status: 202
  end

  def import_corrections
    job_status = JobStatus.create!(
      name: "Creación de correccion - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :uploadable,
      file: params[:file]
    )
    stage_id = params[:filter]

    job = ImportCorrectionJob.perform_later(job_status, stage_id)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def import_charges
    job_status = JobStatus.create!(
      name: "Creación de Pagos iniciales - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :uploadable,
      file: params[:file]
    )
    stage_id = params[:filter]

    job = ImportPaymentsJob.perform_later(job_status, stage_id)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end


  def download_charges
    send_file "public/formato_cargos.xlsx", type: "application/xls", status: 202
  end

  def import_client_user
    job_status = JobStatus.create!(
      name: "Creación de responsables de clientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :up_and_downloadable,
      file: params[:file]
    )

    job = ImportClientUserJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def import_folders
    job_status = JobStatus.create!(
      name: "Creación de expedientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: :uploadable,
      file: params[:file]
    )

    job = FolderImportJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def template_folder
    job_status = JobStatus.create!(name: "Plantilla de expediente - #{Time.zone.now.strftime("%m/%d/%Y %I:%M%p ")}", user: current_user, status: "pending")
    job = ExportFolderTemplateJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end
end
