# frozen_string_literal: true

class CreateLeadSources < ActiveRecord::Migration[5.2]
  def change
    create_table :lead_sources do |t|
      t.string :name, null: false, default: ""
      t.string :source_key, null: false, default: ""
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
