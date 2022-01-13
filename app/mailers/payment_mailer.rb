# frozen_string_literal: true

class PaymentMailer < ApplicationMailer
  include InstallmentConcern

  def send_invoice(email, pdf, client, payment, project_singular, phase_singular, stage_singular)
    @payment = payment
    @cash_flow = payment.cash_flow

    @client = client
    @folder = payment.installment.folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @project_singular = project_singular
    @phase_singular = phase_singular
    @stage_singular = stage_singular

    attachments["comprobante_de_pago_#{payment.installment.folder.lot.reference}.pdf"] = build_pdf(pdf)

    mail(to: email, subject: "Confirmación de pago").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def send_account_status(email, pdf, client, folder, project_singular, phase_singular, stage_singular)
    @client = client
    @folder = folder

    @lot = folder.lot
    @stage = folder.stage
    @phase = folder.phase
    @project = folder.project

    @phase_singular = phase_singular
    @stage_singular = stage_singular
    @project_singular = project_singular

    attachments["estado_de_cuenta_#{@reference}.pdf"] = build_pdf(pdf)

    mail(to: email, subject: "Estado de cuenta").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def notify_payment_to_stakeholders(email, pdf, client, payment, project_singular, phase_singular, stage_singular)
    @payment = payment
    @cash_flow = payment.cash_flow
    @folder = payment.installment.folder

    @lot = @folder.lot
    @stage = @folder.stage
    @phase = @folder.phase
    @project = @folder.project

    @project_singular = project_singular
    @phase_singular = phase_singular
    @stage_singular = stage_singular

    attachments["comprobante_de_pago_#{payment.installment.folder.lot.reference}.pdf"] = build_pdf(pdf)
    mail(to: email, subject: "Notificación de pago").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def payment_due_soon(email, client, folder, day)
    @client = client
    @folder = folder

    @today = Time.zone.now.day
    @day = day

    @due_today = @day == @today

    @lot = folder.lot
    @stage = folder.stage
    @phase = folder.phase
    @project = folder.project

    @online_payment_service = @stage.enterprise.available_netpay_service

    subject = @online_payment_service.present? ? "Ya puedes realizar el pago de tu #{@project.lot_entity_name} desde aquí" : "Tu fecha límite de pago está próxima"

    mail(to: email, subject: subject).tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def canceled_payment(email, client, payment, project_singular, phase_singular, stage_singular)
    @client = client
    @folio = payment.cash_flow.folio

    @folder = payment.installment.folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @stage_singular = stage_singular
    @phase_singular = phase_singular
    @project_singular = project_singular

    mail(to: email, subject: "Pago rechazado").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def notify_new_cashflow(cash_flow)
    @cash_flow = cash_flow
    @project = cash_flow.folder.project
    @subject = "#{@project.name} - Comprobante de pago aplicado"
    attachments["comprobante_de_pago_#{cash_flow.folder.lot.reference}.pdf"] = cash_flow.to_file(true, false, false).to_pdf

    mail(to: @cash_flow.client.email, subject: @subject).tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def notify_new_payment(payment)
    @payment = payment
    @project = payment.installment.folder.project
    @subject = "#{@project.name} - Cambio en tu estructura de pagos"
    attachments["comprobante_de_restructura_#{payment.installment.folder.lot.reference}.pdf"] = payment.to_file(true, false, false).to_pdf

    mail(to: @payment.client.email, subject: @subject).tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
