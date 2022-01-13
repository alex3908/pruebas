# frozen_string_literal: true

class CreateClientUserConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :client_user_concepts do |t|
      t.string :name
      t.string :key, default: "custom"
      t.integer :max_users
      t.timestamps
    end
  end
end
