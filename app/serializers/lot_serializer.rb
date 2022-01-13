# frozen_string_literal: true

class LotSerializer < ActiveModel::Serializer
  attributes :id, :rid, :name, :depth, :front, :price, :stage
end
