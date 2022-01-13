# frozen_string_literal: true

class CreateContractNonSigners < ActiveRecord::Migration[5.2]
  def change
    create_table :contract_non_signers do |t|
      t.references :contract, foreign_key: true, index: true
      t.integer :non_signer_id, index: true

      t.timestamps
    end

    add_foreign_key "contract_non_signers", "signers", column: "non_signer_id"
  end
end
