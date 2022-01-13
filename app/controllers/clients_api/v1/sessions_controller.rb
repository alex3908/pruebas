# frozen_string_literal: true

class ClientsApi::V1::SessionsController < ClientsAPI::V1::BaseController
  before_action :find_client, :password_auth, only: [:create]
  def create
    render json: custom_json({ token: @user_client.authentication_token }), status: 200
  end

  def recovery_password
    @user_client = UserClient.find_by(email: session_params[:email])

    if @user_client.present?
      @user_client.send_email_reset_instructions
      render json: custom_json({ message: "Email enviado correctamente" }), status: 200
    else
      render json: custom_json({ message: "Usuario no encontrado" }), status: 400
    end
  end

  def custom_json(data)
    ActiveModelSerializers::SerializableResource.new(data)
  end


  private

    def session_params
      params.require(:session).permit(:email, :password)
    end

    def find_client
      @user_client = UserClient.find_by(email: session_params[:email])
      return render json: custom_json({ message: "No existe el usuario" }), status: :unauthorized unless @user_client.present?
    end

    def password_auth
      @password_auth = @user_client.authenticate(session_params[:password])
      return render json: custom_json({ message: "La contraseña es incorrecta" }), status: :unauthorized unless @password_auth
    end
end
