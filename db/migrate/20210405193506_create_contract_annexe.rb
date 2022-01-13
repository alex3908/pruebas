# frozen_string_literal: true

class CreateContractAnnexe < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_annexes do |t|
      t.references :contract, index: true, foreign_key: true
      t.integer :annexe_id, null: false
      t.integer :order, null: false
      t.integer :amount, null: false, default: 0

      t.timestamps
    end
  end
end
