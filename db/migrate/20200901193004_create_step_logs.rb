# frozen_string_literal: true

class CreateStepLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :step_logs do |t|
      t.references :step, index: true, null: true, foreign_key: true
      t.references :folder, index: true, null: false, foreign_key: true
      t.references :user, index: true, null: false, foreign_key: true
      t.string :status, null: false
      t.datetime :moved_at, default: -> { "CURRENT_TIMESTAMP" }

      t.timestamps
    end
  end
end
