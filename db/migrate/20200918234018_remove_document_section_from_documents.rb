# frozen_string_literal: true

class RemoveDocumentSectionFromDocuments < ActiveRecord::Migration[5.2]
  def change
    remove_reference :documents, :document_section, index: true
  end
end
