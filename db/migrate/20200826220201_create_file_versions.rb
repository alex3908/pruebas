# frozen_string_literal: true

class CreateFileVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :file_versions do |t|
      t.belongs_to :document, foreign_key: true
      t.timestamps
    end
  end
end
