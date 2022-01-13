# frozen_string_literal: true

class BlueprintSerializer < ActiveModel::Serializer
  attributes :id, :available_color, :reserved_color, :sold_color
end
