# frozen_string_literal: true

class ClientsApi::V1::AdditionalConceptSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :name, :description, :amount
end
