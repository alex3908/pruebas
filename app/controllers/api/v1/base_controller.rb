# frozen_string_literal: true

# Base class API controller

class API::V1::BaseController < ActionController::API
  include ExceptionHandler

  # called before every action on controllers
  before_action :authenticate
  before_action :set_paginate
  attr_accessor :current_user
  helper NumberHelper

  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :bad_request
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { errors: "Usted no está autorizado para usar este recurso." }, status: :unauthorized
  end

  def initialize
    # Initialize the Bad Request code for use in controllers response
    @per_page_default = 10
  end

  def authenticate
    header_api_key = request.headers["X-API-KEY"]
    return authorize_request(header_api_key) unless header_api_key.blank?

    # header_jwt = request.headers["Authorization"]
    # return decode_token(header_jwt) unless header_jwt.blank?
    raise(ExceptionHandler::AuthenticationError, "Ingese un método de autentificación")
  rescue StandardError => e
    render json: { errors: e.message }, status: :unauthorized
  end

  private

    def set_paginate
      @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    end

    # Check for valid request token and return user

    def authorize_request(api_key_header)
      key = api_key_header.split(":")
      raise(ExceptionHandler::AuthenticationError, Message.invalid_api_key) unless key.size == 2

      api_key = ApiKey.where(public_key: Base64.decode64(key[0])).first
      raise(ExceptionHandler::AuthenticationError, Message.invalid_api_key) if api_key.blank?
      raise(ExceptionHandler::AuthenticationError, Message.invalid_api_key) unless api_key.private_key == Base64.decode64(key[1])

      self.current_user = api_key.user
    end

    def decode_token(header)
      token = header.split(" ").last
      @decoded_token = JsonWebToken.decode(token)
      self.current_user = User.find(@decoded_token[:user_id])
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
end
