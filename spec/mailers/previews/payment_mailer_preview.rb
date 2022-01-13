# frozen_string_literal: true

class PaymentMailerPreview < ActionMailer::Preview
  def send_invoice
    folder = Folder.last
    payment = folder.installments.first.payments.first
    project = folder.lot.project
    PaymentMailer.send_invoice(folder.client.email, fake_pdf, folder.client, payment, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def send_account_status
    folder = Folder.last
    project = folder.lot.project
    PaymentMailer.send_account_status(folder.client.email, fake_pdf, folder.client, folder, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def notify_payment_to_stakeholders
    folder = Folder.last
    payment = folder.installments.first.payments.first
    project = folder.lot.project
    PaymentMailer.notify_payment_to_stakeholders(folder.client.email, fake_pdf, folder.client, payment, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def payment_due_soon
    folder = Folder.last
    payment_date = folder.installments.financing.last.date.to_s

    PaymentMailer.payment_due_soon(folder.client.email, folder.client, folder, payment_date)
  end

  def canceled_payment
    folder = Folder.last
    payment = folder.installments.first.payments.first
    project = folder.lot.project
    PaymentMailer.canceled_payment(folder.client.email, folder.client, payment, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  private
    # ToDo: Replace with real quotation
    def fake_pdf
      "<html><body><h1 align='center'>Test Document</h1></body></html>"
    end
end
