# frozen_string_literal: true

class API::V1::SalesmanSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :email, :first_name, :last_name, :phone, :role
end
