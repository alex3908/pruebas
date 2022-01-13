# frozen_string_literal: true

class AddDocumentFormatsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :formats, :string, array: true, default: []
  end
end
