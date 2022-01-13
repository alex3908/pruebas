# frozen_string_literal: true

class CreateStageAdditionalConcepts < ActiveRecord::Migration[5.2]
  def change
    create_table :stage_additional_concepts do |t|
      t.references :additional_concept, index: true, foreign_key: true
      t.references :stage, index: true, foreign_key: true
      t.timestamps
    end
  end
end
