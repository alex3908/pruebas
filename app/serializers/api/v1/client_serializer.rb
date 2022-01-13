# frozen_string_literal: true

class API::V1::ClientSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :name, :first_surname, :second_surname, :main_phone, :optional_phone, :email, :user_id, :person
end
