# frozen_string_literal: true

class CreateAdditionalConceptPayments < ActiveRecord::Migration[5.2]
  def change
    create_table :additional_concept_payments do |t|
      t.references :cash_flow, foreign_key: true
      t.references :additional_concept, foreign_key: true
      t.string :amount_type
      t.timestamps
    end
  end
end
