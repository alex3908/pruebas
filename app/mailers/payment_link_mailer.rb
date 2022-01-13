# frozen_string_literal: true

class PaymentLinkMailer < ApplicationMailer
  def send_payment_link(folder, client, type)
    @client = client
    @folder = folder
    @type = type

    @project = @folder.lot.stage.phase.project
    @phase = @folder.lot.stage.phase
    @stage = @folder.lot.stage
    @lot = @folder.lot

    @project_singular = @project.project_entity_name
    @phase_singular = @project.phase_entity_name
    @stage_singular = @project.stage_entity_name


    mail(to: @client.email, subject: "Servicio de pagos en línea").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
