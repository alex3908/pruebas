# frozen_string_literal: true

class CreateClientUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :client_users do |t|
      t.references :client, index: true, foreign_key: true
      t.integer :user_id
      t.references :client_user_concept, index: true, foreign_key: true
      t.timestamps
    end
  end
end
