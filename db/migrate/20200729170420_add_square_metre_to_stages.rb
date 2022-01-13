# frozen_string_literal: true

class AddSquareMetreToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :show_price, :boolean, default: false
  end
end
