# frozen_string_literal: true

class SendPublicQuotationJob < ApplicationJob
  queue_as :high_priority

  def perform(quotation, pdf, current_user, project, stage, lot, client, company_name, stage_singular, phase_singular, project_singular)
    quotation = Quotation.new(quotation)
    amr = quotation.amr.each_slice(20).to_a
    html = ApplicationController.new.render_to_string(pdf, layout: "pdf", assigns: { amr: amr, quotation: quotation, project: project, stage: stage, lot: lot, client: client, credit_scheme: stage.credit_scheme }, locals: { current_user: current_user.presence || client.sales_executive })

    QuotationMailer.send_quotation(html, client, lot, client.sales_executive, company_name).deliver_later
    QuotationMailer.notify_user(client.sales_executive, client, lot, stage_singular, phase_singular, project_singular, company_name).deliver_later
    QuotationMailer.notify_project(project.email, lot).deliver_later
  end
end
