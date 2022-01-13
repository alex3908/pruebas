# frozen_string_literal: true

class PreviewTemplateMailer < ApplicationMailer
  def send_preview(email_template, emails = [])
    @html = PreviewEmailTemplate.new(email_template).get_html

    mails = mail(to: emails, subject: email_template.subject) do |format|
      format.html { render layout: email_template.use_system_template ? "mailer" : false }
    end

    mails.tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
