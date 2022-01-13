# frozen_string_literal: true

class NotifyPaymentJob < ApplicationJob
  queue_as :high_priority

  def perform(*args)
    folder = args[0]
    payment = args[1]
    quotation = Quotation.new(args[2])
    branches = args[3]
    project = args[4]
    html = ApplicationController.new.render_to_string("installments/new_format/invoice.html.erb", layout: "pdf", assigns: { folder: folder, payment: payment, quotation: quotation, branches: branches, project: project, project_singular: project.project_entity_name, phase_singular: project.phase_entity_name, stage_singular: project.stage_entity_name })
    if folder.active_mails
      PaymentMailer.send_invoice(folder.client.email, html, folder.client, payment, project.project_entity_name, project.phase_entity_name, project.stage_entity_name).deliver_later
    end

    if folder.stage.payment_receptor_emails.present? && folder.active_mails
      folder.stage.payment_receptor_emails.each do |email|
        PaymentMailer.notify_payment_to_stakeholders(email, html, folder.client, payment, project.project_entity_name, project.phase_entity_name, project.stage_entity_name).deliver_later
      end
    end

    if folder.stage.active_messages
      folder_installments = folder.installments.where(folder: folder, deleted_at: nil)
      next_payment = folder_installments.where("id > (?)", payment.installment.id).first

      if next_payment.present?
        folder.clients.each do |client|
          message = "Hola #{client[:name]} te recordamos que la fecha de su próximo pago es el #{next_payment.date}. Si ya realizó el pago ignore este mensaje."
          phone = client[:main_phone].present? ? client[:main_phone] : client[:optional_phone]
          ApplicationTexter.message(phone, message).deliver_now
        end
      end
    end
  end
end
