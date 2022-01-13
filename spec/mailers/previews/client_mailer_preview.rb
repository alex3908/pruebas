# frozen_string_literal: true

class FolderMailerPreview < ActionMailer::Preview
  def send_email_confirmation
    client = Client.where(confirmed_email: false).last
    ClientMailer.send_email_confirmation(client)
  end
end
