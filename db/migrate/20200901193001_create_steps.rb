# frozen_string_literal: true

class CreateSteps < ActiveRecord::Migration[5.2]
  def change
    create_table :steps do |t|
      t.string :name
      t.integer :order
      t.integer :reject_step_id, index: true, null: true
      t.integer :hubspot_id
      t.datetime :deleted_at

      t.timestamps
    end

    add_foreign_key "steps", "steps", column: "reject_step_id"
  end
end
