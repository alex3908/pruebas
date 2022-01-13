# frozen_string_literal: true

class AddLotDescriptionTitleToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :lot_description_title, :string
  end
end
