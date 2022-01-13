# frozen_string_literal: true

class Api::V1::SessionsController < ActionController::API
  def create
    @user = User.find_by_email(sesion_params[:email])
    raise(ExceptionHandler::AuthenticationError, "Este usuario no existe") unless @user.present?
    raise(ExceptionHandler::AuthenticationError, "Este usuario no está activo") unless @user.is_active
    raise(ExceptionHandler::AuthenticationError, "Las credenciales que estas usando no son validas") unless @user.valid_password?(sesion_params[:password])
    @authentication_token = JsonWebToken.encode({ user_id: @user.id, first_name: @user.first_name, last_name: @user.last_name, phone: @user.phone, role: @user.role.key })
    @exp_time = 24.hours.from_now
    render :create, status: :created
    rescue => exception
      render json: { message: exception.message }, status: :unauthorized
  end
  private
    def sesion_params
      params.require(:session).permit(:email, :password)
    end
end
