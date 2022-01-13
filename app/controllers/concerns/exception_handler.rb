# frozen_string_literal: true

module ExceptionHandler
  extend ActiveSupport::Concern

  # Define custom error subclasses - rescue catches `StandardErrors`
  class AuthenticationError < StandardError
  end
  class MissingToken < StandardError
  end
  class InvalidToken < StandardError
  end

  included do
    # Define custom handlers

    rescue_from StandardError do |e|
      case e.class.name
      when  ExceptionHandler::AuthenticationError.name || ExceptionHandler::MissingToken.name || ExceptionHandler::InvalidToken.name
        unauthorized_request
      when ActiveRecord::RecordNotFound.name
        not_found
      when ActiveRecord::RecordInvalid.name
        error
      when ActionController::ParameterMissing.name
        error
      else
        error
      end
    end
  end

  def custom_json(data)
    ActiveModelSerializers::SerializableResource.new(data)
  end

  private

    # JSON response with message; Status code 422 - unprocessable entity
    def four_twenty_two(e)
      json_response({ message: e.message }, :unprocessable_entity)
    end

    # JSON response with message; Status code 401 - Unauthorized
    def unauthorized_request(e)
      render json: custom_json({ message: I18n.t("devise.failure.invalid_token"), status: 401 }),
             status: :unauthorized
    end

    def not_found
      render json: custom_json({ message: I18n.t("errors.messages.not_found"), status: 404 }),
             status: :not_found
    end

    def error
      render json: custom_json({ message: I18n.t("errors.messages.error"), status: 500 }),
      status: :internal_server_error
    end
end
