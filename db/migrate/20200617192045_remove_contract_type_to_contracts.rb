# frozen_string_literal: true

class RemoveContractTypeToContracts < ActiveRecord::Migration[5.2]
  def change
    remove_column :contracts, :contract_type
  end
end
