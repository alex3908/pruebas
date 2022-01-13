# frozen_string_literal: true

class StagesCommissionSchemesRole < ApplicationRecord
  belongs_to :stage
  belongs_to :commission_schemes_role

  validates :stage, :commission_schemes_role, presence: true

  delegate :commission, to: :commission_schemes_role
  delegate :folder_user_concept, to: :commission_schemes_role
end
