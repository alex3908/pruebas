# frozen_string_literal: true

class CreateTinyUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :tiny_uploads do |t|
      t.string :key

      t.timestamps
    end
  end
end
