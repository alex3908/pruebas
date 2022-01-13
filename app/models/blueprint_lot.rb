# frozen_string_literal: true

class BlueprintLot < ApplicationRecord
  belongs_to :blueprint
  belongs_to :lot, optional: true
end
