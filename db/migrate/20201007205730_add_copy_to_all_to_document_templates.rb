# frozen_string_literal: true

class AddCopyToAllToDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :copy_to_all, :boolean, default: false
  end
end
