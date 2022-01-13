# frozen_string_literal: true

class CreateClassifiers < ActiveRecord::Migration[5.2]
  def change
    create_table :classifiers do |t|
      t.string :name

      t.timestamps
    end
  end
end
