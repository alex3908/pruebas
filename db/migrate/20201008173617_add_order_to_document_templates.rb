# frozen_string_literal: true

class AddOrderToDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    add_column :document_templates, :order, :integer
  end
end
