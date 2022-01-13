# frozen_string_literal: true

class StepDocument < ApplicationRecord
  belongs_to :step
  belongs_to :document_template
end
