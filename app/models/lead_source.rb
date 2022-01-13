# frozen_string_literal: true

class LeadSource < ApplicationRecord
  validates :name, allow_blank: false, presence: true
  validates :source_key, allow_blank: false, presence: true, uniqueness: true

  has_many :clients

  def self.set_params(params, sort_column, sort_direction)
    search(params).order(sort_column + " " + sort_direction)
  end

  def is_active
    self.active
  end
end
