# frozen_string_literal: true

class CreateDigitalSignatures < ActiveRecord::Migration[5.2]
  def change
    create_table :digital_signatures do |t|
      t.references :folder, index: true, foreign_key: true
      t.json :response_data
      t.string :service_type
      t.string :document_type
      t.string :document_external_id
      t.string :status
      t.timestamps
    end
  end
end
