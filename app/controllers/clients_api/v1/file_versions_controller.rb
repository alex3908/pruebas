# frozen_string_literal: true

class ClientsApi::V1::FileVersionsController < ClientsAPI::V1::BaseController
  def show
    file_version = FileVersion.find(params[:id])
    render json: file_version
  end
end
