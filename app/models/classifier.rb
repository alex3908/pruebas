# frozen_string_literal: true

class Classifier < ApplicationRecord
  has_many :classifier_users
  has_many :users, through: :classifier_users

  has_many :classifier_roles
  has_many :roles, through: :classifier_roles
end
