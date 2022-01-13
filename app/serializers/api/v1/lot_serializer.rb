# frozen_string_literal: true

class API::V1::LotSerializer < API::V1::BaseSerializer
  attributes :id, :rid, :name, :depth, :front, :area, :price, :status, :stage_id
end
