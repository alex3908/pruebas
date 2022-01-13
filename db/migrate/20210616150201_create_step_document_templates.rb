# frozen_string_literal: true

class CreateStepDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :step_document_templates do |t|
      t.references :step, index: true, foreign_key: true
      t.references :document_template, index: true, foreign_key: true

      t.timestamps
    end
  end
end
