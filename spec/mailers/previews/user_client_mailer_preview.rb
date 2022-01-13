# frozen_string_literal: true

class UserClientMailerPreview < ActionMailer::Preview
  def send_email_reset_instructions
    UserClientMailer.send_email_reset_instructions(UserClient.first)
  end
end
