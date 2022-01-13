# frozen_string_literal: true

class StagePromotion < ApplicationRecord
  belongs_to :promotion
  belongs_to :stage
end
