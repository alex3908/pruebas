# frozen_string_literal: true

class AddKeyToDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :key, :string
  end
end
