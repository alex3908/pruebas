# frozen_string_literal: true

class AdditionalConcept < ApplicationRecord
  acts_as_paranoid
  enum amount_type: { fixed: 0, variable: 1 }

  scope :active, ->() { where(active: true) }

  has_many :stage_additional_concepts, dependent: :destroy
  has_many :stages, through: :stage_additional_concepts
  has_many :additional_concept_payments

  belongs_to :enterprise

  validates :name, presence: true
  validates :amount_type, presence: true
  validates :amount, numericality: true, presence: true
end
