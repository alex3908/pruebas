# frozen_string_literal: true

class ReportsController < ApplicationController
  include DateHelper
  authorize_resource class: false
  skip_before_action :verify_authenticity_token, except: [:show, :future_cash_flow_request]
  before_action :set_projects
  before_action :set_roles, only: [:commissions, :folder_users, :commision_dispersion]
  before_action :set_folder_user_concepts, only: [:commissions, :folder_users, :commision_dispersion]
  before_action :set_ransack_for_payments, only: [:payments, :payments_request]

  def show
    # @sales_chart_data = generate_sales_data
  end

  def commissions
    render "reports/commissions/show"
  end

  def payments
    render "reports/payments/show"
  end

  def payments_request
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:payments, :report)
    payments = @q.result.pluck(:id)

    job_status = JobStatus.create!(name: "Reporte de pagos - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = PaymentReportJob.perform_later(job_status, payments)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def overdue_balances
    @users = User.all
    @folder_user_concepts = FolderUserConcept.all

    render "reports/overdue_balances/show"
  end

  def file_approvals
    @branches = Branch.all.order(id: :ASC)
    render "reports/file_approvals/show"
  end

  def balances_close_to_due
    render "reports/balances_close_to_due/show"
  end

  def future_cash_flow
    render "reports/future_cash_flow/show"
  end

  def future_cash_flow_request
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:future_cash_flow, :report)

    job_status = JobStatus.create!(name: "Reporte de flujos proyectados - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = FutureCashFlowReportJob.perform_later(job_status, params.permit(:from_date, :to_date, :email, :name, :salesman, :project, :phase, :stage))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def step
    render "reports/steps/show"
  end

  def delays
    render "reports/delays/show"
  end

  def folder_users
    render "reports/folder_users/show"
  end

  def additional_concept_payments
    render "reports/additional_concept_payments/show"
  end

  def commision_dispersion
    render "reports/commision_dispersion/show"
  end

  def online_payment_tickets
    render "reports/online_payment_tickets/show"
  end

  def online_payment_tickets_request
    job_status = JobStatus.create!(name: "Reporte de tickets de pago - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = OnlinePaymentTicketsReportJob.perform_later(job_status, params.permit(:from_date, :to_date, :folio, :name, :lot_number, :lot_label, :project, :phase, :stage, :concept, :status))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def clients
    if current_user.structure.present? && current_user.role.level.present?
      @first_evo_searcher = current_user.structure.children
      @subordinate = current_user.role.next
    else
      level = Role.root
      @first_evo_searcher = Structure.where(role_id: level&.id)
      @subordinate = level
    end

    @first_evo_searcher = @first_evo_searcher.where.not(user_id: nil)
    @concepts = ClientUserConcept.custom
    @sales_executive = ClientUserConcept.sales_executive
    @lead_sources = LeadSource.all
    render "reports/clients/show"
  end

  def clients_request
    job_status = JobStatus.create!(name: "Reporte de clientes - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = ClientsReportJob.perform_later(job_status, params.permit(*Role.evo_structure.map { |r| r.key.+ "_node" }, :from_date, :to_date, :lead_source, concept: {}).to_h)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def units
    render "reports/units/show"
  end

  def folders
    @branches = Branch.all.order(id: :asc)
    render "reports/folders/show"
  end

  def users_kpi
    if current_user.structure.present? && current_user.role.level.present?
      @first_evo_searcher = current_user.structure.children
      @subordinate = current_user.role.next
    else
      level = Role.root
      @first_evo_searcher = Structure.where(role_id: level&.id)
      @subordinate = level
    end

    @first_evo_searcher = @first_evo_searcher.where.not(user_id: nil)

    render "reports/users_kpi/show"
  end

  def users_kpi_request
    job_status = JobStatus.create!(name: "Reporte Kpi - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = UsersKpiReportJob.perform_later(job_status, params.permit(*Role.evo_structure.map { |r| r.key.+ "_node" }))

    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def users
    if current_user.structure.present? && current_user.role.level.present?
      @first_evo_searcher = current_user.structure.children
      @subordinate = current_user.role.next
    else
      level = Role.root
      @first_evo_searcher = Structure.where(role_id: level&.id)
      @subordinate = level
    end

    @first_evo_searcher = @first_evo_searcher.where.not(user_id: nil)
    render "reports/users/show"
  end

  def users_request
    job_status = JobStatus.create!(name: "Reporte de Usuarios - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = UsersReportJob.perform_later(job_status, params.permit(*Role.evo_structure.map { |r| r.key.+ "_node" }))

    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def quote_logs
    render "reports/quote_logs/show"
  end

  def quote_logs_request
    job_status = JobStatus.create!(name: "Reporte de cotizaciones - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = QuoteLogsReportJob.perform_later(job_status, params.permit(:from_date, :to_date, :folio, :name, :lot_number, :lot_label, :project, :phase, :stage, :concept, :status))

    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def referred_clients
    render "reports/referred_clients/show"
  end

  def referred_clients_request
    job_status = JobStatus.create!(name: "Reporte de clientes referidos - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = ReferredClientsReportJob.perform_later(job_status, params.permit(:from_date, :to_date))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def referred_users
    render "reports/referred_users/show"
  end

  def referred_users_request
    job_status = JobStatus.create!(name: "Reporte de usuarios referidos - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = ReferredUsersReportJob.perform_later(job_status, params.permit(:from_date, :to_date))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def sales
    @steps = Step.all
    render "reports/sales/show"
  end

  def sales_request
    job_status = JobStatus.create!(name: "Reporte de ventas realizadas - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = SalesReportJob.perform_later(job_status, params.permit(:from_date, :to_date, :approved_date_from_date, :approved_date_to_date, :status, :step))
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end



  private
    def generate_sales_data
      data = {}

      folders = Folder.group("extract(month from folders.created_at)").joins(:installments).where(created_at: 3.months.ago...Date.today).sum("installments.capital + installments.down_payment")
      folders = Hash[folders.sort]

      month_names = I18n.t("date.month_names")

      folders.each do |key, value|
        data[month_names[key.to_i]] = value.to_s
      end

      data
    end

    def set_projects
      @projects = Project.includes(phases: :stages).order(id: :asc)
    end

    def set_roles
      @roles = Role.permitted(can?(:view_hidden, Role)).all
    end

    def set_folder_user_concepts
      @folder_user_concepts = FolderUserConcept.all
    end

    def set_ransack_for_payments
      @q = Payment.ransack(params[:q])
    end
end
