# frozen_string_literal: true

module Response
  class Error
    attr_reader :message

    def initialize(message)
      @message = message
    end
  end

  def json_response(object, status = :ok, include = [])
    render json: object, status: status, include: include
  end

  def json_error_response(object, status = :ok, include = [])
    code = nil

    if status == :unprocessable_entity
      code = 422
    elsif status == :not_found
      code = 404
    end

    render json: { message: object, status: status, code: code }, status: status, include: include
  end
end
