# frozen_string_literal: true

class UserClientsController < ApplicationController
  load_and_authorize_resource except: [:reset_password, :update_password, :success_recovery]

  def create
    client = Client.find(params[:client])
    @user_client.email = client.email
    @user_client.client_id = client.id
    password = SecureRandom.hex(6)
    @user_client.password = password
    @user_client.uid = Time.new.to_i

    if @user_client.save
      UserClientMailer.send_app_invite(@user_client, password).deliver_later
      redirect_to clients_path, success: "Usuario del app creado. #{@user_client.password}"
    else
      redirect_to clients_path, flash: { error: "Ocurrio un error #{@user_client.errors.full_messages}" }
    end
  end

  def reset_password
    @reset_password_token = params[:rpt]
    @decoded_token = decode_token @reset_password_token
    if @decoded_token
      @user_client = UserClient.find(@decoded_token[:user_client_id])
      if @user_client && @user_client.reset_password_token == @reset_password_token
        respond_to do |format|
          format.html { render layout: "devise" }
        end
      else
        redirect_to root_path, alert: "El tiempo ha expirado"
      end
    else
      redirect_to root_path, alert: "El tiempo ha expirado"
    end
  end

  def update_password
    @user_client = UserClient.find(update_password_params[:user_client_id])
    if @user_client.update(password: update_password_params[:password], password_confirmation: update_password_params[:password_confirmation])
      @user_client.update(reset_password_token: nil)
      redirect_to "/success_password_recovery", notice: "Contraseña guardada correctamente"
    else
      flash.now[:alert] = "Ingresa la misma contraseña"
      respond_to do |format|
        format.html { render :reset_password, layout: "devise", notice: "Las contraseñas deben conincidir" }
        format.json { render json: @user_client.errors, status: :unprocessable_entity }
      end
    end
  end

  def success_recovery
    respond_to do |format|
      format.html { render layout: "devise" }
    end
  end

  def recovery_password
    return redirect_to clients_path, flash: { success: "Aún no se tiene un usuario para la app." } unless @user_client.present?

    begin
      @user_client.send_email_reset_instructions
    rescue StandardError => ex
      Bugsnag.notify(ex)
      redirect_to clients_path, flash: { error: "Ocurrió un error al enviar el correo de recuperación de contraseña." }
    end
    redirect_to clients_path, flash: { success: "Se ha enviado correctamente el correo de recuperación de contraseña." }
  end

  private
    def decode_token(token)
      decoded_token = JsonWebToken.decode(token)
    rescue ExceptionHandler::InvalidToken
      return false
      decoded_token
    end

    def update_password_params
      params.require(:user_client).permit(:user_client_id, :password, :password_confirmation)
    end
end
