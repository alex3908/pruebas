# frozen_string_literal: true

class ClientsApi::V1::ClientUserSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :name, :email, :phone, :client_user_concept, :created_at, :updated_at

  def name
    object.user.label
  end

  def email
    object.user.email
  end

  def phone
    object.user.phone
  end

  def client_user_concept
    object.client_user_concept.name
  end
end
