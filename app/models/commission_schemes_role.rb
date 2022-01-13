# frozen_string_literal: true

class CommissionSchemesRole < ApplicationRecord
  belongs_to :commission_scheme
  belongs_to :role
  belongs_to :folder_user_concept

  has_many :stages_commission_schemes_roles, dependent: :destroy

  validates :commission_scheme, :role, :folder_user_concept, presence: true
  validates :commission, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
