# frozen_string_literal: true

class FolderMailer < ApplicationMailer
  def notify_expiration(email, expired, date)
    @folders = JSON.parse(expired)
    @date = date

    mail(to: email, subject: "Notificación de expiraciones").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
