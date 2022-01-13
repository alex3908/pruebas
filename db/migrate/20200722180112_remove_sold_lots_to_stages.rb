# frozen_string_literal: true

class RemoveSoldLotsToStages < ActiveRecord::Migration[5.2]
  def change
    remove_column :stages, :sold_lots
  end
end
