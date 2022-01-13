# frozen_string_literal: true

class ClientMailer < ApplicationMailer
  def send_email_confirmation(client)
    @client = client
    mail(to: client.email, subject: "Instrucciones de confirmación").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
