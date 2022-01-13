# frozen_string_literal: true

class EvaluationFolder < ApplicationRecord
  scope :newest, -> { order(:created_at).last }
  scope :rejected, -> { joins(:evaluation).where("evaluations.question_type = 'reject' AND evaluation_folders.answer = 'Si'") }
  scope :canceled, -> { joins(:evaluation).where("evaluations.question_type = 'cancel' AND evaluation_folders.answer = 'Si'") }

  belongs_to :evaluation
  belongs_to :folder
  belongs_to :user
end
