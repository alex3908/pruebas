# frozen_string_literal: true

class RemoveNameFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_column :documents, :name, :string, null: true
  end
end
