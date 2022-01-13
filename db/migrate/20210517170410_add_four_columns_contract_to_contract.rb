class AddFourColumnsContractToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :four_columns, :boolean, default: false
  end
end
