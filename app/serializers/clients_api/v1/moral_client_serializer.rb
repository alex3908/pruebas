# frozen_string_literal: true

class ClientsApi::V1::MoralClientSerializer < ClientsApi::V1::BaseSerializer
  def attributes(*args)
    object.attributes.symbolize_keys
  end
end
