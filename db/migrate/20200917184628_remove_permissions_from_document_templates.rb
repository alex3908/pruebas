# frozen_string_literal: true

class RemovePermissionsFromDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    remove_column :document_templates, :permissions, :integer, default: 0
  end
end
