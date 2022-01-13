# frozen_string_literal: true

class CreateBlueprintStages < ActiveRecord::Migration[5.2]
  def change
    create_table :blueprint_stages do |t|
      t.string :html_type
      t.string :html_class, null: true
      # PATH VARS
      t.string :points
      # RECT VARS
      t.string :x
      t.string :y
      t.string :width
      t.string :height
      t.string :transform
      t.string :d
      t.references :blueprint, index: true, foreign_key: true
      t.references :stage, index: true, foreign_key: true

      t.timestamps
    end
  end
end
