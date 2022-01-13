# frozen_string_literal: true

json.extract! @lot, :id, :name, :area, :status, :created_at, :updated_at
json.chepina rails_blob_url(@lot.chepina, disposition: "inline") if @lot.chepina.attached?
