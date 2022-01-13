# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.string :name
      t.references :folder, index: true, null: false, foreign_key: true
      t.integer :permissions, default: 0
      t.boolean :requires_approval, default: false
      t.timestamps
    end
  end
end
