# frozen_string_literal: true

class AddKeyToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :key, :string
  end
end
