# frozen_string_literal: true

class ApprovalsMailerPreview < ActionMailer::Preview
  def send_approved
    ApprovalsMailer.send_approved(FactoryBot.build(:user))
  end
end
