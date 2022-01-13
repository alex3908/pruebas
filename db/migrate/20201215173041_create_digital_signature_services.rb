# frozen_string_literal: true

class CreateDigitalSignatureServices < ActiveRecord::Migration[5.2]
  def change
    enable_extension "hstore"
    create_table :digital_signature_services do |t|
      t.string :name
      t.string :environment
      t.boolean :is_automatic
      t.references :enterprise, foreign_key: true, index: true
      t.references :step, index: true, foreign_key: true
      t.hstore :properties
      t.timestamps
    end
  end
end
