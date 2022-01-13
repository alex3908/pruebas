# frozen_string_literal: true

class BlueprintLotSerializer < ActiveModel::Serializer
  attributes :id, :html_type, :points, :x, :y, :width, :height, :blueprint
end
