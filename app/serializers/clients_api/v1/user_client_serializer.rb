# frozen_string_literal: true

class ClientsApi::V1::UserClientSerializer < ClientsApi::V1::BaseSerializer
  attributes :personal_info, :address_attributes, :salesman, :additional_info

  def personal_info
    object.client
  end

  def address_attributes
    object.client.address_attributes
  end

  def salesman
    object.client.sales_executive
  end

  def additional_info
    object.client.get_person
  end
end
