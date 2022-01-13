# frozen_string_literal: true

class FileApprovalsController < ApplicationController
  before_action :set_file_approval, only: [:approve, :reject]
  before_action :set_file_approval_type
  helper_method :sort_column, :sort_direction

  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @projects = Project.includes(phases: :stages).order(id: :asc)
    @branches = Branch.all.order(id: :ASC)
    @file_approval_type = params[:type]

    @q = FileApproval.ransack(params[:q])

    if @file_approval_type == FileApproval::TYPE[:DOCUMENT]
      @file_approvals = @q.result.paginate(page: params[:page], per_page: params[:per_page])
    elsif @file_approval_type == FileApproval::TYPE[:USER]
      @file_approvals = FileApproval.of_users(params).set_order(params, sort_column, sort_direction)
    end
  end

  def approve
    @file_approval.approve
    redirect_to file_approvals_path, success: "Se aprobó correctamente el archivo."
  end

  def reject
    @file_approval.reject(params)

    respond_to do |format|
      format.js
    end
  end

  def rejectable_file
    respond_to do |format|
      format.html
      format.js
    end
  end

  def export
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:payments, :report)
    file_approvals = FileApproval.with_folders(params).pluck(:id)

    job_status = JobStatus.create!(name: "Reporte de verificaciones - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = FileApprovalReportJob.perform_later(job_status, file_approvals)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  private

    def set_file_approval
      @file_approval = FileApproval.find(params[:id])
    end

    def set_file_approval_type
      if params[:type].nil? || [FileApproval::TYPE[:DOCUMENT], FileApproval::TYPE[:USER]].exclude?(params[:type])
        return redirect_to file_approvals_path(type: FileApproval::TYPE[:DOCUMENT]) if can?(:verify, DocumentTemplate)
        return redirect_to file_approvals_path(type: FileApproval::TYPE[:USER]) if can?(:verify_user_file, User)
        raise ActionController::RoutingError.new("Not Found")
      end

      if (params[:type] == FileApproval::TYPE[:DOCUMENT] && cannot?(:verify, DocumentTemplate)) || (params[:type] == FileApproval::TYPE[:USER] && cannot?(:verify_user_file, User))
        raise CanCan::AccessDenied.new("No tienes permisos para verificar documentos")
      end
    end

    def sort_column
      if FileApproval.column_names.include?(params[:sort]) || ["project_id", "phase_id", "stage_id", "lot_id"].include?(params[:sort])
        return "projects.name" if params[:sort] == "project_id"
        return "phases.name" if params[:sort] == "phase_id"
        return "stages.name" if params[:sort] == "stage_id"
        return "lots.name" if params[:sort] == "lot_id"
        return "file_approvals.created_at" if params[:sort] == "created_at"
        params[:sort]
      else
        "file_approvals.created_at"
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
