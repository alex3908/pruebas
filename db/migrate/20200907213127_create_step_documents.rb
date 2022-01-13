# frozen_string_literal: true

class CreateStepDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :step_documents do |t|
      t.references :step, index: true, null: false, foreign_key: true
      t.references :document_template, index: true, null: false, foreign_key: true
      t.boolean :required, default: false

      t.timestamps
    end
  end
end
