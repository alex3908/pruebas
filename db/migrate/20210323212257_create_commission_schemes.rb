# frozen_string_literal: true

class CreateCommissionSchemes < ActiveRecord::Migration[5.2]
  def change
    create_table :commission_schemes do |t|
      t.string :name
      t.decimal :global_commission

      t.timestamps
    end
  end
end
