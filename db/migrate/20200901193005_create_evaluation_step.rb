# frozen_string_literal: true

class CreateEvaluationStep < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluation_steps do |t|
      t.references :evaluation, index: true, null: true, foreign_key: true
      t.references :step, index: true, null: true, foreign_key: true

      t.timestamps
    end
  end
end
