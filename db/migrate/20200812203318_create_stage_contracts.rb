# frozen_string_literal: true

class CreateStageContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :stage_contracts do |t|
      t.references :stage, index: true, null: true, foreign_key: true
      t.references :contract, index: true, null: true, foreign_key: true
      t.timestamps
    end
  end
end
