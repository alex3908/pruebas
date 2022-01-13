# frozen_string_literal: true

class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    Devise::Mailer.reset_password_instructions(FactoryBot.build(:user), Faker::Number.number(digits: 10))
  end

  def email_changed
    Devise::Mailer.email_changed(FactoryBot.build(:user))
  end

  def password_change
    Devise::Mailer.password_change(FactoryBot.build(:user))
  end
end
