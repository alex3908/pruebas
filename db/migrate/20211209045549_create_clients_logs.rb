# frozen_string_literal: true

class CreateClientsLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :clients_logs do |t|
      t.string :action
      t.integer :client_id
      t.integer :client_user_concept_id
      t.integer :client_users_id
      t.datetime :moved_at, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end
  end
end
