# frozen_string_literal: true

class ClientsApi::V1::InstallmentSerializer < ClientsApi::V1::BaseSerializer
  attributes :id, :number, :date, :concept, :total

  def total
    object.class
  end
end
