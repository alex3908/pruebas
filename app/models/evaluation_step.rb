# frozen_string_literal: true

class EvaluationStep < ApplicationRecord
  belongs_to :evaluation
  belongs_to :step
end
