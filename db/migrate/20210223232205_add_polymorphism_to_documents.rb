# frozen_string_literal: true

class AddPolymorphismToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :documentable, polymorphic: true
    change_column_null :documents, :folder_id, true
    remove_foreign_key :documents, :folders
  end
end
