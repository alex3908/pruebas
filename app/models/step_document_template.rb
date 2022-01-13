# frozen_string_literal: true

class StepDocumentTemplate < ApplicationRecord
  belongs_to :step
  belongs_to :document_template
end
