# frozen_string_literal: true

class StageContract < ApplicationRecord
  belongs_to :stage
  belongs_to :contract
end
