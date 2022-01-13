# frozen_string_literal: true

class CreateRolesClientUserConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :roles_client_user_concepts do |t|
      t.references :role, index: true, foreign_key: true
      t.references :client_user_concept, index: true, foreign_key: true
      t.timestamps
    end
  end
end
