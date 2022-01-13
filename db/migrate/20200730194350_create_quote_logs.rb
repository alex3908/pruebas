# frozen_string_literal: true

class CreateQuoteLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :quote_logs do |t|
      t.references :lot, index: true, null: true, foreign_key: true
      t.references :client, index: true, null: true, foreign_key: true
      t.references :user, index: true, null: true, foreign_key: true
      t.references :folder, index: true, null: true, foreign_key: true
      t.date :creation_date, default: -> { "CURRENT_TIMESTAMP" }
      t.boolean :email_delivered, default: false
      t.boolean :downloaded, default: false
      t.timestamps
    end
  end
end
