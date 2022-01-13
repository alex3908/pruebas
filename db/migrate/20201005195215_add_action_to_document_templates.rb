# frozen_string_literal: true

class AddActionToDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :action, :string, null: true
  end
end
