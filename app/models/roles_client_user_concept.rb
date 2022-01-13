# frozen_string_literal: true

class RolesClientUserConcept < ApplicationRecord
  belongs_to :role
  belongs_to :client_user_concept
end
