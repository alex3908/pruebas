# frozen_string_literal: true

class AddTotalSaleToFolders < ActiveRecord::Migration[5.2]
  def change
    add_column :folders, :total_sale, :numeric
  end
end
