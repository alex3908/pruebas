# frozen_string_literal: true

class CreateStepRole < ActiveRecord::Migration[5.2]
  def change
    create_table :step_roles do |t|
      t.references :step, index: true, null: true, foreign_key: true
      t.references :role, index: true, null: true, foreign_key: true
      t.boolean :update_financial, default: false
      t.boolean :update_coowners, default: false
      t.boolean :can_cancel, default: false
      t.boolean :can_approve, default: false
      t.boolean :can_soft_reject, default: false
      t.boolean :can_reject, default: false
      t.string :readable_files, null: true
      t.string :uploadable_files, null: true
      t.string :editable_files, null: true
      t.string :destroyable_files, null: true

      t.timestamps
    end
  end
end
