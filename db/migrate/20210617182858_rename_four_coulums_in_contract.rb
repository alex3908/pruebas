# frozen_string_literal: true

class RenameFourCoulumsInContract < ActiveRecord::Migration[5.2]
  def change
    rename_column :contracts, :four_columns, :two_columns
  end
end
