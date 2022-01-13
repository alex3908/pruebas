# frozen_string_literal: true

class ClientsApi::V1::DocumentTemplatesController < ClientsAPI::V1::BaseController
  def index
    render json: DocumentTemplate.visible
  end
end
