# frozen_string_literal: true

class ClientsApi::V1::UsersController < ClientsAPI::V1::BaseController
  def customer_service
    specialist_concept = FolderUserConcept.find_by_key(:customer_service_specialist)
    folder = current_user.client.folders.find_by!(id: params[:folder_id])
    customer_service_specialist = folder.folder_users.find_by(folder_user_concept: specialist_concept).try(:user)
    render json: customer_service_specialist
  end
end
