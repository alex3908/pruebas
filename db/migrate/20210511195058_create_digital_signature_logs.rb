# frozen_string_literal: true

class CreateDigitalSignatureLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :digital_signature_logs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :digital_signature, index: true, foreign_key: true
      t.string :status
      t.datetime :date
      t.timestamps
    end
  end
end
