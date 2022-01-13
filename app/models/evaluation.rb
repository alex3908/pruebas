# frozen_string_literal: true

class Evaluation < ApplicationRecord
  EVALUATION_TYPES = { REJECT: "reject", APPROVE: "approve", CANCEL: "cancel" }

  has_many :evaluation_folders
  has_many :folders, through: :evaluation_folders
  has_many :evaluation_steps, dependent: :destroy
  has_many :steps, through: :evaluation_steps

  scope :active, -> { where(active: true) }
end
