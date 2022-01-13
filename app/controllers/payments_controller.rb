# frozen_string_literal: true

class PaymentsController < ApplicationController
  include QuotationsHelper, EntityNamesConcern
  load_and_authorize_resource
  before_action :set_folder, :set_project_entity_names_by_project, except: [:export, :delays]
  before_action :generate, only: [:index, :invoice]

  def index
    @cash_flows = @folder.cash_flows.includes(:client, :branch, :payment_method, payments: [:installment, :restructure])
    @payments = Payment.joins(:restructure).includes(:installment).where(installment: @folder.installments, cash_flow: nil).where.not(restructure: nil)
  end

  def resend_notification
    @payment.send_email(resend: true)
  end

  def invoice
    voucher = (params[:type] == "voucher")
    disposition = (params[:download] == "true") ? "attachment" : "inline"
    invoice = @payment.to_file(false, voucher, voucher)

    respond_to do |format|
      format.pdf { send_data invoice.to_pdf, filename: "invoice.pdf", type: "application/pdf", disposition: disposition }
      format.html { render html: invoice.render_to_string } unless Rails.env.production?
    end
  end

  def cancel
    locals = {}
    payment = Payment.find(params[:id])
    if params[:cancelation_description].blank?
      locals[:message] = "empty_description"
    else
      if payment.update(status: Payment::STATUS[:CANCELED], canceled_by: current_user, cancelation_date: Time.zone.now, cancelation_description: params[:cancelation_description])
        locals[:message] = "canceled_payment"
      else
        locals[:message] = "error"
      end
    end

    respond_to do |format|
      format.js { render "payments/cancel", locals: locals }
    end
  end

  def export
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:payments, :report)
    payments = Payment.search(params: params).pluck(:id)

    job_status = JobStatus.create!(name: "Reporte de pagos - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = PaymentReportJob.perform_later(job_status, payments)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def delays
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:delays, :report)
    payments = Payment.joins(:restructure).where("restructures.concept IN (?)", ([Restructure::CONCEPT[:DELAY_IMMEDIATE],
                                                                                  Restructure::CONCEPT[:DELAY_ALTERNATE],
                                                                                  Restructure::CONCEPT[:DELAY_LAST]])
    ).search(params: params, hide_restructures: false).pluck(:id)

    job_status = JobStatus.create!(name: "Reporte de prórrogas - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = DelayedRestructuresReportJob.perform_later(job_status, payments)
    job_status.update(job_id: job.provider_job_id)

    respond_to do |format|
      format.json { render job_status }
    end
  end

  def see_cancel_modal
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def set_folder
      @folder = Folder.includes(:payment_scheme, :client, lot: { stage: { phase: :project } }).find(params[:folder_id])
      @client = @folder.client
      @project = @folder.project
      @phase = @folder.phase
      @stage = @folder.stage
      @lot = @folder.lot
      @payment_scheme = @folder.payment_scheme
    end

    def generate
      @quotation = @folder.generate_quote
    end
end
