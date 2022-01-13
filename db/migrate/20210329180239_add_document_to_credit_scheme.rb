# frozen_string_literal: true

class AddDocumentToCreditScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :requires_file, :boolean, default: false
    add_reference :credit_schemes, :document_template, index: true, foreign_key: true
  end
end
