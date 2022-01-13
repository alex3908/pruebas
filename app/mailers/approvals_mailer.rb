# frozen_string_literal: true

class ApprovalsMailer < ApplicationMailer
  def send_approved(user)
    @user_name = user.label
    @company_name = Setting.find_by(key: "company-name").try(:convert)
    mail(to: user.email, subject: "Tu cuenta ha sido aprobada").tap do |message|
      message.mailgun_options = mailgun_options
    end
  end
end
