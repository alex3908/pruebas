# frozen_string_literal: true

class CreateJobStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :job_statuses do |t|
      t.integer :status, default: 0
      t.text :error_message
      t.text :log
      t.string :name
      t.datetime :expires_at, null: true
      t.references :user, index: true, foreign_key: true


      t.timestamps
    end
  end
end
