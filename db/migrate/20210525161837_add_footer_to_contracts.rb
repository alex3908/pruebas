# frozen_string_literal: true

class AddFooterToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :footer, :text
  end
end
