# frozen_string_literal: true

class CreateStepRoleDocumentTemplate < ActiveRecord::Migration[5.2]
  def change
    create_table :step_role_document_templates do |t|
      t.references :step_role, index: true, null: true, foreign_key: true
      t.references :document_template, index: true, null: false, foreign_key: true
      t.boolean :readable, default: false
      t.boolean :editable, default: false
      t.boolean :uploadable, default: false
      t.boolean :destroyable, default: false

      t.timestamps
    end
  end
end
