# frozen_string_literal: true

class AutomatedEmailMailer < ApplicationMailer
  def send_automated_email(element, automated_email)
    if automated_email.email_template.attachments.attached?
      automated_email.email_template.attachments.each do |attachment|
        attachments["#{attachment.filename}"] = attachment.download
      end
    end

    recipients = Array.new

    case automated_email.automated_type
    when AutomatedEmail.types[:folders]
      email_template = automated_email.email_template
      @project = element.project

      @html = EmailFolderTemplate.new(element, email_template).get_html

      if automated_email.reciever_type == AutomatedEmail.recievers[:client]
        recipients = element.clients.pluck(:email)
      elsif automated_email.reciever_type == AutomatedEmail.recievers[:user]
        recipients = element.folder_users.where(folder_user_concept: automated_email.folder_user_concepts).map { |folder_user| folder_user.user.email }
      elsif automated_email.reciever_type == AutomatedEmail.recievers[:client_users]
        recipients = element.client.client_users.where(client_user_concept: automated_email.client_user_concepts).map { |client_user| client_user.user.email }
      end

      unless automated_email.emails_information.blank?
        recipients = recipients + automated_email.emails_information.split(",")
      end
    when AutomatedEmail.types[:clients]
      # elsif automated_email.clients?
      email_template = automated_email.email_template

      @html = EmailClientTemplate.new(element, email_template).get_html
      recipients = element.email

      unless automated_email.emails_information.blank?
        recipients = recipients + automated_email.emails_information.split(",")
      end
    else
      recipients = []
    end

    if recipients.length > 0
      mails = mail(to: recipients, subject: email_template.subject) do |format|
        format.html { render layout: email_template.use_system_template ? "mailer" : false }
      end

      mails.tap do |message|
        message.mailgun_options = mailgun_options
      end
    end
  end
end
