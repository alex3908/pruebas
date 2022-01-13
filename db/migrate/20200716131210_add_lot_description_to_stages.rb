# frozen_string_literal: true

class AddLotDescriptionToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :lot_description, :text
  end
end
