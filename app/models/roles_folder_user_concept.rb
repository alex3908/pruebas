# frozen_string_literal: true

class RolesFolderUserConcept < ApplicationRecord
  belongs_to :role
  belongs_to :folder_user_concept
end
