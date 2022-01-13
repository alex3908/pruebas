# frozen_string_literal: true

class CreateContractDocumentTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_document_templates do |t|
      t.references :contract, index: true, foreign_key: true
      t.references :document_template, index: true, foreign_key: true

      t.timestamps
    end
  end
end
