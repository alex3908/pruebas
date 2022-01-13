# frozen_string_literal: true

class AutomatedEmailMailerPreview < ActionMailer::Preview
  def send_automated_email
    AutomatedEmailMailer.send_automated_email(Folder.first, AutomatedEmail.first).deliver_later
  end
end
