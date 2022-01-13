# frozen_string_literal: true

class CreateReferenceContacts < ActiveRecord::Migration[5.2]
  def change
    create_table :reference_contacts do |t|
      t.references :client, foreign_key: true
      t.string :name
      t.string :email
      t.string :phone
      t.string :concept

      t.timestamps
    end
  end
end
