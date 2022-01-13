# frozen_string_literal: true

class CreateOnlinePaymentTickets < ActiveRecord::Migration[5.2]
  def change
    create_table :online_payment_tickets do |t|
      t.string :concept
      t.string :concept_key
      t.string :sku
      t.string :amount
      t.string :token
      t.string :status
      t.string :message
      t.references :client, index: true, foreign_key: true
      t.references :online_payment_service, index: true, foreign_key: true
      t.references :folder, index: true, foreign_key: true

      t.timestamps
    end
  end
end
