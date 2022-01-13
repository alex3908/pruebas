# frozen_string_literal: true

class ClientsApi::V1::ClientsController < ClientsAPI::V1::BaseController
  def info
    render json: current_user
  end

  def show
    render json: current_user.client
  end

  def document
    render json: current_user.client.document_by_template_id(params[:document_template_id])
  end

  def documents
    render json: current_user.client.documents.select { |doc| doc.latest_file_version.present? }
  end

  def salesman
    render json: current_user.client.sales_executive
  end

  def responsible
    render json: current_user.client.client_users
  end

  private

    def set_client_folders
      @folders = Folder.where(client: current_user.client)
    end
end
