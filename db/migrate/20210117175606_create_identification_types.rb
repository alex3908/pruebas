# frozen_string_literal: true

class CreateIdentificationTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :identification_types do |t|
      t.string :name
      t.string :institution
      t.string :display_as

      t.timestamps
    end
  end
end
