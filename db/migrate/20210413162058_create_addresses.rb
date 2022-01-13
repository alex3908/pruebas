# frozen_string_literal: true

class CreateAddresses < ActiveRecord::Migration[5.2]
  def change
    create_table :addresses do |t|
      t.references :addressable, polymorphic: true
      t.string :country
      t.string :postal_code
      t.string :state
      t.string :city
      t.string :colony
      t.string :location
      t.string :street
      t.string :house_number
      t.string :interior_number

      t.timestamps
    end
  end
end
