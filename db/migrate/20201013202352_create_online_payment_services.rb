# frozen_string_literal: true

class CreateOnlinePaymentServices < ActiveRecord::Migration[5.2]
  def change
    enable_extension "hstore"
    create_table :online_payment_services do |t|
      t.string :provider
      t.string :alias
      t.string :environment
      t.hstore :properties
      t.references :enterprise, foreign_key: true, index: true

      t.timestamps
    end
  end
end
