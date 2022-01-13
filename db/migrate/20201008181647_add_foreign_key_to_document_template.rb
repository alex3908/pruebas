# frozen_string_literal: true

class AddForeignKeyToDocumentTemplate < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :document_templates, :document_sections
  end
end
