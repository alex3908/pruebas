# frozen_string_literal: true

class AddOrderToDocumentSections < ActiveRecord::Migration[5.2]
  def change
    add_column :document_sections, :order, :integer
  end
end
