# frozen_string_literal: true

class PromotionSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :amount, :min_area, :max_area, :active
end
