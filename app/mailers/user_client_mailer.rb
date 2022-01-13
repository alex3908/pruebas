# frozen_string_literal: true

class UserClientMailer < ApplicationMailer
  def send_email_reset_instructions(user_client)
    @user_client = user_client
    mail(to: user_client.email, subject: "Instrucciones de recuperacion de contraseña").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end

  def send_app_invite(user_client, password)
    @user_client = user_client
    @password = password
    mail(to: @user_client.email, subject: "Instrucciones de confirmación").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
