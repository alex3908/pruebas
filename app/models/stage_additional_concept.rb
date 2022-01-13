# frozen_string_literal: true

class StageAdditionalConcept < ApplicationRecord
  belongs_to :stage
  belongs_to :additional_concept
end
