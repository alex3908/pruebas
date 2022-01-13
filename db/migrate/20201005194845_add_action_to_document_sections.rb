# frozen_string_literal: true

class AddActionToDocumentSections < ActiveRecord::Migration[5.2]
  def change
    add_column :document_sections, :action, :string, null: true
  end
end
