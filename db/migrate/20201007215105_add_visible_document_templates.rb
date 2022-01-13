# frozen_string_literal: true

class AddVisibleDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :visible, :boolean, default: true
  end
end
