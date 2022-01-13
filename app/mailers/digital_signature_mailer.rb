# frozen_string_literal: true

class DigitalSignatureMailer < ApplicationMailer
  default from: Rails.application.secrets.app_emailer

  def send_signature_addresses(folder, participant)
    @folder = folder
    @sign_link = participant.sign_url
    client = Client.find_by(email: participant.email)
    if client.present?
      @client = client
      @participant_name = client.label.upcase
      @company_name = (Setting.find_by(key: "company-name").try(:convert) || "Nombre de compañia").upcase
      mail(to: participant.email, subject: "¡ESTÁS A UN PASO DE CERRAR TU COMPRA CON #{@company_name}!").tap do |message|
        message.mailgun_options = {
          "tracking-opens" => true,
          "tracking-clicks" => "htmlonly"
        }
      end
    end
  rescue StandardError => ex
    participant.update_attributes(email_send: false)
    Bugsnag.notify(ex)
  end

  def send_signature_to_legal_representative(folder, participant)
    @folder = folder
    @sign_link = participant.sign_url
    signer = Signer.find_by(email: participant.email)
    if signer.present?
      @participant_name = signer.label.upcase
      mail(to: participant.email, subject: "¡Se ha cerrado una nueva venta del proyecto #{ @folder.project.name }!").tap do |message|
        message.mailgun_options = {
          "tracking-opens" => true,
          "tracking-clicks" => "htmlonly"
        }
      end
    end
  rescue StandardError => ex
    participant.update_attributes(email_send: false)
    Bugsnag.notify(ex)
  end

  def send_signature_to_observer(folder, participant)
    @folder = folder
    @document_link = participant.sign_url
    signer = Signer.find_by(email: participant.email)
    if signer.present?
      @participant_name = signer.label.upcase
      mail(to: participant.email, subject: "¡Revisión de firma de contrato del proyecto #{ @folder.project.name }!").tap do |message|
        message.mailgun_options = {
          "tracking-opens" => true,
          "tracking-clicks" => "htmlonly"
        }
      end
    end
  rescue StandardError => ex
    participant.update_attributes(email_send: false)
    Bugsnag.notify(ex)
  end

  def send_signed_document(folder, document_link, nom_document_link, email)
    @folder = folder
    @client = Client.find_by(email: email)
    @project = folder.project
    @participant_name = @client.present? ? @client.label.upcase : email

    @company_name = (Setting.find_by(key: "company-name").try(:convert) || "Nombre de compañia").upcase
    @document_link = document_link
    @nom_document_link = nom_document_link
    mail(to: email, subject: "¡BIENVENIDO A #{@company_name}!").tap do |message|
      message.mailgun_options = {
        "tracking-opens" => true,
        "tracking-clicks" => "htmlonly"
      }
    end
  end

  def send_signed_document_to_legal_representative(folder, document_link, email, signer)
    @folder = folder
    @document_link = document_link
    @participant_name = signer.present? ? signer.label.upcase : email
    mail(to: email, subject: "¡Se ha finalizado una nueva firma de contrato del proyecto #{ @folder.project.name }!").tap do |message|
      message.mailgun_options = {
        "tracking-opens" => true,
        "tracking-clicks" => "htmlonly"
      }
    end
  end

  def send_signed_document_to_user(folder)
    @folder = folder
    @user = folder.user
    mail(to: @user.email, subject: "¡Se ha finalizado la firma de contrato del expediente #{@folder.id}!").tap do |message|
      message.mailgun_options = {
        "tracking-opens" => true,
        "tracking-clicks" => "htmlonly"
      }
    end
  end

  def send_sign_notification(folder, participant, signer_participant)
    @folder = folder
    client = Client.find_by(email: participant.email)
    signer = Signer.find_by(email: signer_participant.email)
    @project = @folder.project
    @participant_name = client.present? ? client.label.upcase : participant.email
    @signer_name = signer.present? ? signer.label.upcase : signer_participant.email
    @company_name = (Setting.find_by(key: "company-name").try(:convert) || "Nombre de compañia").upcase
    @lot = @folder.lot
    @stage = @folder.lot.stage
    mail(to: signer_participant.email, subject: "FIRMA DE PARTICIPANTE").tap do |message|
      message.mailgun_options = {
        "tracking-opens" => true,
        "tracking-clicks" => "htmlonly"
      }
    end
  rescue StandardError => ex
    Bugsnag.notify(ex)
  end
end
