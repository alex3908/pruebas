# frozen_string_literal: true

class AddDocumentTemplateToDigitalSinatureServices < ActiveRecord::Migration[5.2]
  def change
    add_reference :digital_signature_services, :document_template, index: true, foreign_key: true
  end
end
