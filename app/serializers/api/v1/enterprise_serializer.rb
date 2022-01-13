# frozen_string_literal: true

class API::V1::EnterpriseSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :business_name, :short_business_name, :rfc, :state, :country,
              :location, :street, :outdoor_number, :indoor_number, :colony
end
