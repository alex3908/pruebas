# frozen_string_literal: true

class ClientsApi::V1::ClientSerializer < ClientsApi::V1::BaseSerializer
  attributes :id,
  :name,
  :first_surname,
  :second_surname,
  :main_phone,
  :optional_phone,
  :email,
  :person,
  :additional

  def additional
    if object.physical? && object.physical_client.present?
      ClientsApi::V1::PhysicalClientSerializer.new(object.physical_client).attributes
    elsif object.moral? && object.moral_client.present?
      ClientsApi::V1::MoralClientSerializer.new(object.moral_client).attributes
    end
  end
end
