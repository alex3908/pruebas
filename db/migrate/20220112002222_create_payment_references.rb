# frozen_string_literal: true

class CreatePaymentReferences < ActiveRecord::Migration[5.2]
  def change
    create_table :payment_references do |t|
      t.string :reference
      t.bigint :folder_id
      t.json :response

      t.timestamps
    end
  end
end
