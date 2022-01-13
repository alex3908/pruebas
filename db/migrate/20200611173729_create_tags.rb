# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false, default: ""
      t.string :key, null: false, default: ""
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
