# frozen_string_literal: true

class AddPaginatedToContracts < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :paginated, :boolean, default: false
  end
end
