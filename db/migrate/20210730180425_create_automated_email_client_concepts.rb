# frozen_string_literal: true

class CreateAutomatedEmailClientConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :automated_email_client_concepts do |t|
      t.references :automated_email, index: true, null: true, foreign_key: true
      t.references :client_user_concept, index: true, null: true, foreign_key: true
      t.timestamps
    end
  end
end
