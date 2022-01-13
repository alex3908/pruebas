# frozen_string_literal: true

class API::V1::ProjectSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :name, :currency, :email, :phone
end
