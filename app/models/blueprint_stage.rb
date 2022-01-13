# frozen_string_literal: true

class BlueprintStage < ApplicationRecord
  belongs_to :blueprint
  belongs_to :stage, optional: true
end
