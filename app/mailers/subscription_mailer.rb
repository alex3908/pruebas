# frozen_string_literal: true

class SubscriptionMailer < ApplicationMailer
  def subscription_invitation(email, client, folder, project_singular, phase_singular, stage_singular)
    @client = client
    @folder = folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @project_singular = project_singular
    @phase_singular = phase_singular
    @stage_singular = stage_singular

    mail(to: email, subject: "Ya puedes domiciliar los pagos de tu lote").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def confirm_subscription(email, client, folder, payment_day, project_singular, phase_singular, stage_singular)
    @payment_day = payment_day

    @client = client
    @folder = folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @project_singular = project_singular
    @phase_singular = phase_singular
    @stage_singular = stage_singular

    mail(to: email, subject: "Domiciliación exitosa").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def confirm_update_subscription(email, client, folder, payment_day, project_singular, phase_singular, stage_singular)
    @payment_day = payment_day

    @client = client
    @folder = folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @project_singular = project_singular
    @phase_singular = phase_singular
    @stage_singular = stage_singular

    mail(to: email, subject: "Tarjeta actualizada").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def confirm_subscription_payment(email, pdf, client, subscription, amount, project_singular, phase_singular, stage_singular)
    @amount = amount

    @client = client
    @folder = subscription.folder
    @subscription = subscription

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @stage_singular = stage_singular
    @phase_singular = phase_singular
    @project_singular = project_singular

    attachments["comprobante_de_pago_#{@lot.reference}.pdf"] = build_pdf(pdf)

    mail(to: email, subject: "Confirmación de pago").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def subscription_payment_error(email, client, folder, amount)
    @amount = amount
    @date = Time.zone.now

    @client = client
    @folder = folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @lot_singular = @project.lot_entity_name
    @stage_singular = @project.stage_entity_name
    @phase_singular = @project.phase_entity_name
    @project_singular = @project.project_entity_name

    mail(to: email, subject: "Error en un pago domiciliado").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def payment_error(client, folder)
    @client = client
    @folder = folder
    @lot = folder.lot

    mail(to: @client.email, subject: "¡Se ha realizado un intento fallido de cobro!").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def card_soon_to_expire(email, client, subscription, project_singular, phase_singular, stage_singular)
    @client = client
    @folder = subscription.folder
    @subscription = subscription

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @stage_singular = stage_singular
    @phase_singular = phase_singular
    @project_singular = project_singular

    mail(to: email, subject: "Tarjeta pronto a vencer").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def subscription_soon_to_finish(email, client, subscription, project_singular, phase_singular, stage_singular)
    @client = client
    @subscription = subscription
    @folder = subscription.folder

    @project = @folder.project
    @phase = @folder.phase
    @stage = @folder.stage
    @lot = @folder.lot

    @stage_singular = stage_singular
    @phase_singular = phase_singular
    @project_singular = project_singular

    mail(to: email, subject: "Subscripción pronto a vencer").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
