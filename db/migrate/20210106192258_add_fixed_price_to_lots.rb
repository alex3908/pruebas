# frozen_string_literal: true

class AddFixedPriceToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :fixed_price, :decimal
  end
end
