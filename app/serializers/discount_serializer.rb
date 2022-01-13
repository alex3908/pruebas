# frozen_string_literal: true

class Discountserializer < ActiveModel::Serializer
  attributes :id, :name, :down_payment, :discount, :total_payments, :is_active
end
