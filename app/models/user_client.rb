# frozen_string_literal: true

class UserClient < ApplicationRecord
  validates :password, confirmation: { message: "La contraseña debe coincidir" }

  has_secure_password
  belongs_to :client

  # It is considered active if you have ever logged in, however,
  # it can later be improved and considered inactive if some time has passed since the last time you logged in.
  def has_activity?
    last_sign_in_at.present?
  end

  def authentication_token
    update(last_sign_in_at: Time.now)
    encode_jwt(14.hours.from_now)
  end

  def send_email_reset_instructions
    update_reset_password_token()
    UserClientMailer.send_email_reset_instructions(self).deliver_later
  end

  private

    def update_reset_password_token
      self.update(reset_password_token: encode_jwt(12.hours.from_now))
    end

    def encode_jwt(exp_time)
      JsonWebToken.encode({ email: email, user_client_id: id, client_id: client_id }, exp_time)
    end
end
