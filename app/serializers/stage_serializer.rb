# frozen_string_literal: true

class StageSerializer < ActiveModel::Serializer
  attributes :id, :rid, :price, :project, :start_date
end
