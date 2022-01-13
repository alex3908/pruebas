# frozen_string_literal: true

class CreateAdditionalConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_concepts do |t|
      t.string :name
      t.text :description
      t.integer :amount_type, default: 0
      t.decimal :amount
      t.boolean :active, default: true
      t.timestamps
    end
  end
end
