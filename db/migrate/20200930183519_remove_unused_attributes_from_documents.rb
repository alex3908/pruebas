# frozen_string_literal: true

class RemoveUnusedAttributesFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :requires_approval, :boolean, default: false
    remove_column :documents, :permissions, :integer, default: 0
    remove_column :documents, :key, :string
  end
end
