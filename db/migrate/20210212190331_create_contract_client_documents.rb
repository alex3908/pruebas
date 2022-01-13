# frozen_string_literal: true

class CreateContractClientDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_client_documents do |t|
      t.references :contract, index: true, foreign_key: true
      t.integer :client_document_id, null: true

      t.timestamps
    end
  end
end
