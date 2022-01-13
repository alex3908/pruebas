# frozen_string_literal: true

class ClassifierUser < ApplicationRecord
  belongs_to :classifier
  belongs_to :user
end
