# frozen_string_literal: true

class CreateDocumentSections < ActiveRecord::Migration[5.2]
  def change
    create_table :document_sections do |t|
      t.string :name
      t.timestamps
    end

    add_reference :documents, :document_section, index: true
    add_reference :document_templates, :document_section, index: true
  end
end
