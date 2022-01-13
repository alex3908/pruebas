# frozen_string_literal: true

class ClientsApi::V1::UserSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :name, :email, :role, :phone, :is_active, :created_at, :updated_at

  def name
    object.label
  end

  def role
    object.role.name
  end
end
