# frozen_string_literal: true

class AddDocumentTypeToDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :doc_type, :string, null: false, default: "folder"
    add_column :document_templates, :client_type, :string, null: true
  end
end
