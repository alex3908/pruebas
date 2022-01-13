# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[5.2]
  def change
    create_table :subscriptions do |t|
      t.references :folder, index: true, null: true, foreign_key: true
      t.string :subscription_id, null: false
      t.string :status, null: false
      t.integer :exp_year, null: false
      t.integer :exp_month, null: false
      t.integer :last_four_digits, null: false
      t.datetime :last_update, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end
  end
end
