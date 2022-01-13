# frozen_string_literal: true

class ClassifierRole < ApplicationRecord
  belongs_to :classifier
  belongs_to :role
end
