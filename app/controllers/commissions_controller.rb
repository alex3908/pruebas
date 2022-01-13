# frozen_string_literal: true

class CommissionsController < ApplicationController
  load_resource except: [:download, :index]
  authorize_resource
  helper_method :get_translate, :get_paid, :sort_column, :sort_direction
  before_action :set_roles
  before_action :set_folder_user_concepts

  def index
    @projects = Project.includes(phases: :stages).order(id: :asc)
    if can?(:reserve, :quote) || current_user.has_structure?
      own_commissions = FolderUser.where(user: current_user)
      hidden_status = params.fetch(:status, nil) == Commission::STATUS[:CANCELED] ? nil : Commission::STATUS[:CANCELED]
      @commissions = Commission.where(folder_user: own_commissions).where.not(status: hidden_status).set_params(params, sort_column, sort_direction).paginate(page: params[:page], per_page: @per_page)
    else
      @commissions = Commission.set_params(params, sort_column, sort_direction).paginate(page: params[:page], per_page: @per_page)
    end
  end

  def export
    download_limit = Setting.find_by(key: "download_limit").try(:convert)

    if can?(:reserve, :quote)
      @own_commissions = FolderUser.where(user: current_user)
      @commissions = @commissions.where(folder_user: @own_commissions).set_params(params, sort_column, sort_direction).pluck(:id)
    else
      @commissions = @commissions.set_params(params, sort_column, sort_direction).pluck(:id)
    end

    if @commissions.size <= download_limit
      job_status = JobStatus.create!(name: "Panel de comisiones - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
      job = CommissionReportJob.perform_later(job_status, @commissions)
      job_status.update(job_id: job.provider_job_id)
    end

    respond_to do |format|
      format.json do
        if @commissions.size <= download_limit
          render job_status
        else
          render json: { error: :limit_reached }
        end
      end
    end
  end

  def import
    job_status = JobStatus.create!(
      name: "Actualización de comisiones - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}",
      user: current_user,
      status: "pending",
      action: "uploadable",
      file: params[:file]
    )

    job = CommissionUpdateJob.perform_later(job_status)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def show
    @project = @commission.installment.folder.project
    @phase = @commission.installment.folder.phase
    @stage = @commission.installment.folder.stage
    @lot = @commission.installment.folder.lot

    if can?(:see_binnacle, Commission)
      @logs = Log.where(element: "commission", element_id: @commission.id).includes(:user)
    end
  end

  def new
  end

  def edit
  end

  def create
    if @commission.save
      redirect_to project_path(@project), success: "Comisión creada correctamente."
    else
      render :new
    end
  end

  def update
    @commission.status = Commission::STATUS[:PAID] if params.dig(:commission, :voucher).present?
    if @commission.update(commission_params)
      redirect_to commission_path(@commission), success: "Se agregaron correctamente los archivos a la carpeta."
    else
      redirect_to commission_path(@commission), flash: { error: "Hubo un error al subir los archivos." }
    end
  end

  def destroy
    @commission.destroy
    redirect_to commissions_path, success: "Comisión eliminada correctamente."
  end

  def remove_file
    @commission = Commission.find(params[:id])
    attachment = ActiveStorage::Attachment.find(params[:file_id])
    @commission.update(status: Commission::STATUS[:PENDING]) if attachment.name == "voucher"
    attachment.purge
    redirect_to commission_path(@commission), success: "Se elimino correctamente el archivo."
  end

  def download
    @period_from = params[:from_date] if params[:from_date]
    @period_to = params[:to_date] if params[:to_date]
    @own_commissions = FolderUser.where(user: current_user)
    @commissions = Commission.where(folder_user: @own_commissions).where.not(status: Commission::STATUS[:CANCELED]).order(:status, :date_payment_receipt).set_params(params, sort_column, sort_direction)
    @total_paid = @commissions.paid.sum(:amount)
    @total_not_paid = @commissions.pending.sum(:amount)

    respond_to do |f|
      f.pdf { render_pdf "COMISIONES DE #{current_user&.label&.upcase}", "commissions/commissions_export.html.erb", "Landscape" }
      f.html { render file: "commissions/commissions_export.html.erb", layout: "pdf.html" } unless Rails.env.production?
    end
  end

  def export_xlsx
    commissions = get_commissions(params)

    job_status = JobStatus.create!(name: "Reporte de comisiones - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = CommissionXlsxReportJob.perform_later(job_status, commissions.map(&:id))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def export_dispersion
    commissions = get_commissions(params)

    job_status = JobStatus.create!(name: "Reporte de dispersión de comisiones - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = DispersionCommisionReportJob.perform_later(job_status, commissions.map(&:id))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  private

    def commission_params
      params.require(:commission).permit(:voucher, :invoice)
    end

    def get_commissions(params)
      Commission.set_params(params, "commissions.created_at", "desc")
    end

    def set_roles
      @roles = Role.permitted(can?(:view_hidden, Role)).all
    end

    def set_folder_user_concepts
      @folder_user_concepts = FolderUserConcept.all
    end

    def get_translate(key)
      case key
      when "payment_id"
        "Pago del Cliente"
      when "folder_user_id"
        "Comisión base"
      when "amount"
        "Cantidad a pagar"
      when "paid"
        "Estado"
      else
        "Traducci\u00F3n no definida"
      end
    end

    # TODO: Remove this and replace with the model method
    def get_paid(paid)
      paid ? "Pagado" : "Pendiente"
    end

    def sort_column
      if Commission.column_names.include?(params[:sort]) || ["project_id", "phase_id", "stage_id", "lot_id", "payment_id", "user_id", "folder_id", "cash_flow_id"].include?(params[:sort])
        return "payments.number" if params[:sort] == "payment_id"
        return "projects.name" if params[:sort] == "project_id"
        return "phases.name" if params[:sort] == "phase_id"
        return "stages.name" if params[:sort] == "stage_id"
        return "lots.name" if params[:sort] == "lot_id"
        return "users.first_name" if params[:sort] == "user_id"
        return "folders.id" if params[:sort] == "folder_id"
        params[:sort]
      else
        "commissions.created_at"
      end
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
