# frozen_string_literal: true

class CreateDownloadableFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :downloadable_files do |t|
      t.references :step_role, index: true, null: false, foreign_key: true
      t.integer :document, null: false

      t.timestamps
    end
  end
end
