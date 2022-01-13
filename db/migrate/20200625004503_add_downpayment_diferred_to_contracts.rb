# frozen_string_literal: true

class AddDownpaymentDiferredToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :differed_downpayment, :integer
  end
end
