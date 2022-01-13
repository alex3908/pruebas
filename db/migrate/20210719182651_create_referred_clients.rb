# frozen_string_literal: true

class CreateReferredClients < ActiveRecord::Migration[5.2]
  def change
    create_table :referred_clients do |t|
      t.references :client, index: true, foreign_key: true
      t.references :referred_client, index: true, foreign_key: { to_table: "clients" }
      t.timestamps
    end
  end
end
