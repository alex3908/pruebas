# frozen_string_literal: true

class ApplicationTexter < Textris::Base
  default from: Rails.application.secrets.phone_number

  def message(phone, message)
    @message = message
    text to: phone
  end
end
