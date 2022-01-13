# frozen_string_literal: true

class SupportSaleMailer < ApplicationMailer
  def support_notification(folder, recipient, support_sale)
    @folder = folder
    @recipient = recipient
    @support_sale = support_sale
    @project = folder.project
    subject = "Un asesor ha solicitado soporte"

    mail(to: @recipient.email, subject: subject).tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def support_assigned_notification(email, folder, support_sale, supporter, support_coordinator, support_manager)
    @folder = folder
    @support_sale = support_sale
    @supporter = supporter
    @support_coordinator = support_coordinator
    @support_manager = support_manager
    @project = folder.project

    subject = "Tu solicitud de soporte ha sido aprobada"

    mail(to: email, subject: subject).tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def support_rejected_notification(email, request_manager, support_manager, requester, support_sale)
    @support_manager = support_manager
    @requester = requester
    @support_sale = support_sale
    @project = folder.project
    subject = "Solicitud de soporte rechazada por el gerente"

    mail(to: email, subject: subject).tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
