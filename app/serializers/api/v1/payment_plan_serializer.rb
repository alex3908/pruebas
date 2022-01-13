# frozen_string_literal: true

class API::V1::Discountserializer < API::V1::BaseSerializer
  attributes :id, :rid, :name, :down_payment, :discount, :total_payments, :stage_id, :dfp, :is_active
end
