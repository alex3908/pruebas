# frozen_string_literal: true

class AdditionalConceptPaymentsController < ApplicationController
  load_and_authorize_resource

  def export
    raise CanCan::AccessDenied.new("No tienes permisos para generar este reporte") unless can?(:additional_concept_payments, :report)
    payments = AdditionalConceptPayment.search(params: params).pluck(:id)
    job_status = JobStatus.create!(name: "Reporte de pagos de servicios adicionales - #{Time.zone.now.strftime("%I%M%p %m/%d/%Y")}", user: current_user, status: "pending")
    job = AdditionalConceptPaymentsReportJob.perform_later(job_status, payments)
    job_status.update!(job_id: job.provider_job_id)
    respond_to do |format|
      format.json { render job_status }
    end
  end
end
