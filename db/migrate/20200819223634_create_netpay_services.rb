# frozen_string_literal: true

class CreateNetpayServices < ActiveRecord::Migration[5.2]
  def change
    create_table :netpay_services do |t|
      t.integer :service_type
      t.string :secret_key
      t.string :public_key
      t.references :enterprise

      t.timestamps
    end
  end
end
