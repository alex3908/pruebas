# frozen_string_literal: true

class CreateRestructures < ActiveRecord::Migration[5.2]
  def change
    create_table :restructures do |t|
      t.references :payment, index: true, foreign_key: true
      t.string :concept
      t.integer :current_term
      t.decimal :current_discount
      t.integer :current_day

      t.timestamps
    end
  end
end
