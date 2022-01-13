# frozen_string_literal: true

class AddReferencesClientUserConceptsToRoles < ActiveRecord::Migration[5.2]
  def change
    add_reference :client_user_concepts, :role,  foreign_key: true
  end
end
