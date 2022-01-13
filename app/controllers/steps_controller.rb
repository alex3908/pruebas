# frozen_string_literal: true

require "will_paginate/collection"

class StepsController < ApplicationController
  include FoldersHelper
  load_and_authorize_resource
  before_action :other_steps, :set_folder_user_concept, :set_client_user_concept, only: [:new, :edit]
  before_action :set_step, only: :show_pipeline
  before_action :set_document_templates, only: [:new, :create, :edit, :update]

  def index
    @steps = Step.all if can?(:read, Step)
    @deleted_steps = Step.only_deleted.order(:deleted_at) if can?(:see_deleted, Step)
  end

  def show_pipeline
    @max_rows = Setting.find_by(key: "step_column_max_request_rows")&.value || 10
    @branches = Branch.all.order(id: :asc)
    @projects = Project.includes(phases: :stages).order(id: :asc)
    params[:branch] = current_user.branch_id if cannot?(:see_all_branches, Folder)

    @role_view = current_user.role.key.present? ? current_user.role.key.to_sym : nil

    @steps = Step.left_joins(folders: :installments)
      .group("steps.id")
      .joins(:step_roles)
      .where("step_roles.role_id = (?) AND step_roles.visible IS true", current_user.role_id)
  end

  def show
  end

  def new
  end

  def edit
    @unassigned_roles = Role.where.not(id: @step.roles)
    @step_roles = @step.step_roles.includes([:role, :step_role_document_templates]).order(:role_id).to_a
    unless @unassigned_roles.length == 0
      @step_roles << @step.step_roles.build
    end
  end

  def create
    if @step.save
      redirect_to edit_step_path(@step), success: "Paso creado correctamente."
    else
      render :new
    end
  end

  def update
    if @step.update(step_params)
      redirect_to edit_step_path(@step), success: "Se actualizó correctamente el paso."
    else
      redirect_to steps_path, flash: { error: "Hubo un error al actualizar el paso." }
    end
  end

  def destroy
    if @step.folders.size == 0 && @step.referrer_steps.size == 0 && @step.update(order: nil, reject_step: nil) && @step.delete
      redirect_to steps_path, success: "Paso eliminado correctamente."
    elsif @step.folders.size != 0
      redirect_to steps_path, flash: { warning: "Este paso tiene expedientes asignados, no se puede eliminar." }
    elsif @step.referrer_steps.size != 0
      redirect_to steps_path, flash: { warning: "Este paso está referenciado en uno o más pasos." }
    else
      redirect_to steps_path, flash: { error: "Hubo un error al tratar de eliminar este paso." }
    end
  end

  def toggle_block
    @step.toggle!(:blocked)

    respond_to do |format|
      format.js
    end
  end

  def export_historic
    return unless params[:report_date].present?
    job_status = JobStatus.create!(name: "Estado_del_Pipeline_a_la_Fecha_#{params[:report_date]}", user: current_user, status: "pending")
    StepHistoricReportJob.perform_later(job_status, params[:report_date])
    respond_to do |format|
      format.json { render template: "components/job_status", locals: { job_status: job_status } }
    end
  end

  def export_average_times
    job_status = JobStatus.create!(name: "Tiempos_promedio_del_Pipeline", user: current_user, status: "pending")
    StepAverageTimesReportJob.perform_later(job_status)
    respond_to do |format|
      format.json { render template: "components/job_status", locals: { job_status: job_status } }
    end
  end

  def export_elapsed_times_per_folder
    job_status = JobStatus.create!(name: "Tiempos_por_expediente_del_Pipeline", user: current_user, status: "pending")
    StepElapsedTimesPerFolderReportJob.perform_later(job_status)
    respond_to do |format|
      format.json { render template: "components/job_status", locals: { job_status: job_status } }
    end
  end

  private

    def step_params
      params.require(:step)
            .permit(:name,
              :reject_step_id,
              :hubspot_id,
              :installments_step,
              :lot_status,
              :folders_expires,
              :client_user_concept_id,
              :folder_user_concept_id,
              :send_payment_reminder,
              document_template_ids: [],
              step_roles_attributes: [
                  :id,
                  :role_id,
                  :visible,
                  :update_financial,
                  :update_coowners,
                  :can_cancel,
                  :can_approve,
                  :can_soft_reject,
                  :can_reject,
                  :can_make_installments,
                  :can_comment,
                  :can_manage_reminders,
                  :can_add_folder_user,
                  :can_edit_folder_user,
                  :can_remove_folder_user,
                  :can_send_to_sign_purchase_promise,
                  :can_send_to_cancel_sign_purchase_promise,
                  :can_resend_sign_files,
                  :send_by_whatsapp,
                  :send_by_email,
                  :copy_to_clipboard,
                  :can_manage_custom_installments,
                  :show_clients_signature_links,
                  :show_signers_signature_links,
                  :can_send_signature_link_by_whatsapp,
                  :can_send_signature_link_by_email,
                  :can_send_signature_link_by_clipboard,
                  :can_reassign_client,
                  :can_reassign_seller,
                  :_destroy,
                  step_role_document_templates_attributes: [
                    :id,
                    :readable,
                    :editable,
                    :uploadable,
                    :destroyable
                  ],
                  downloadable_files_attributes: [
                    :id,
                    :document
                  ]
                ]
               )
    end

    def set_folder_user_concept
      @folder_user_concepts = FolderUserConcept.all
    end

    def set_client_user_concept
      @client_user_concepts = ClientUserConcept.all
    end

    def other_steps
      @other_steps = @step.persisted? ? Step.where("steps.order < (?)", @step.order) : Step.all
    end

    def set_step
      @step = Step.find(params[:step]) if params[:step].present?
    end

    def set_document_templates
      @folders_documents = DocumentTemplate.for_folders
    end
end
