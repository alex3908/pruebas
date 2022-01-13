# frozen_string_literal: true

class QuotationMailer < ApplicationMailer
  def send_quotation(pdf, client, lot, user, company_name)
    @client_name = client.name
    @project_phone = lot.stage.phase.project.phone
    @user = user
    @company_name = company_name

    @lot = lot
    @stage = @lot.stage
    @phase = @stage.phase
    @project = @phase.project

    @stage_singular = @project.stage_entity_name
    @phase_singular = @project.phase_entity_name
    @project_singular = @project.project_entity_name

    attachments["cotizacion_#{lot.name}_#{lot.stage.phase.project.name}.pdf"] = build_pdf(pdf)

    mail(to: client.email, subject: "#{@company_name} - SOLICITUD DE INFORMACIÓN").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def notify_user(user, client, lot, stage_singular, phase_singular, project_singular, company_name)
    @client = client
    @user = user
    @lot = lot
    @stage = @lot.stage
    @phase = @stage.phase
    @project = @phase.project
    @stage_singular = stage_singular
    @phase_singular = phase_singular
    @project_singular = project_singular
    @company_name = company_name

    mail(to: @user.email, subject: "#{@company_name} - SOLICITUD DE CONTACTO").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def notify_project(email, lot)
    @lot = lot
    @stage = @lot.stage
    @phase = @stage.phase
    @project = @phase.project

    @lot_singular = @project.lot_entity_name
    @stage_singular = @project.stage_entity_name
    @phase_singular = @project.phase_entity_name
    @project_singular = @project.project_entity_name

    mail(to: email, subject: "Cotización del #{@lot_singular} #{@lot.name} de la #{@stage_singular} #{@stage.name} de la #{@phase_singular} #{@phase.name}").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def send_contact_information(emails, stage, phase, client_name, client_last_name, phone, client_message)
    @stage = stage
    @phase = phase
    @project = @phase.project
    @client_name = client_name
    @client_last_name = client_last_name
    @client_phone = phone
    @message = client_message

    @phase_singular = @project.phase_entity_name
    @stage_singular = @project.stage_entity_name

    mail(to: emails, subject: "Información de contacto del cliente #{@client_name} #{@client_last_name} en la #{@stage_singular} #{@stage.name} de la #{@phase_singular} #{@phase.name}").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
