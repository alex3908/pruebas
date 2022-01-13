# frozen_string_literal: true

class AddLotDescriptionToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :description, :text
  end
end
