# frozen_string_literal: true

class AddDocumentTemplateIdToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :document_template, foreign_key: true
  end
end
