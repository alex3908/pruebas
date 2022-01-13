# frozen_string_literal: true

class Branch < ApplicationRecord
  include Filterable

  has_many :users, dependent: :destroy
end
