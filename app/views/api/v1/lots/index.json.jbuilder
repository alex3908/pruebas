# frozen_string_literal: true

json.array! @lots do |lot|
  json.id lot.id
  json.name lot.name
  json.depth text_to_decimal(lot.depth, 6)
  json.front text_to_decimal(lot.front, 6)
  json.area text_to_decimal(lot.area, 6)
  json.price text_to_decimal(lot.price, 6)
  json.status lot.status
  json.map rails_blob_url(lot.map) if lot.map.attached?
  json.chepina rails_blob_url(lot.chepina) if lot.chepina.attached?
end
