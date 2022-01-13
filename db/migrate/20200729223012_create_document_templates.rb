# frozen_string_literal: true

class CreateDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :document_templates do |t|
      t.string :name
      t.integer :permissions, default: 0
      t.boolean :requires_approval, default: false
      t.timestamps
    end
  end
end
