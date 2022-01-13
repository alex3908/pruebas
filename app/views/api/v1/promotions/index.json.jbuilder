# frozen_string_literal: true

json.array! @promotions do |promotion|
  json.id promotion.id
  json.name promotion.name
end
