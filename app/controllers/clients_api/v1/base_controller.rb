# frozen_string_literal: true

class ClientsAPI::V1::BaseController < ActionController::API
  include ExceptionHandler

  before_action :auth, :set_paginate

  def auth
    header_jwt = request.headers["Authorization"]
    method_req = request
    decode_token(header_jwt) unless header_jwt.blank?
    if method_req.get? && !header_jwt
      raise(ExceptionHandler::AuthenticationError, "Ingese un método de autentificación")
    end
  rescue StandardError => e
    render json: custom_json({ errors: e.message }), status: :unauthorized
  end

  def initialize
    # Initialize the Bad Request code for use in controllers response
    @per_page_default = 10
  end

  private

    def set_paginate
      @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    end

    def decode_token(header)
      @decoded_token = JsonWebToken.decode(header)
      rescue JWT::ExpiredSignature => e
        render json: custom_json({ errors: e.message }), status: :unauthorized
      rescue ActiveRecord::RecordNotFound => e
        render json: custom_json({ errors: e.message }), status: :unauthorized
      rescue JWT::DecodeError => e
        render json: custom_json({ errors: e.message }), status: :unauthorized
    end
    def current_user
      UserClient.find_by(email: @decoded_token[:email]) if @decoded_token
    end
end
