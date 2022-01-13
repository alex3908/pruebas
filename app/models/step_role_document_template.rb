
# frozen_string_literal: true

class StepRoleDocumentTemplate < ApplicationRecord
  belongs_to :step_role
  belongs_to :document_template
end
