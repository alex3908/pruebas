# frozen_string_literal: true

class API::V1::StageSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :price, :created_at, :updated_at, :name, :active, :phase_id, :enterprise_id
end
