# frozen_string_literal: true

class RemoveReferencesToPayments < ActiveRecord::Migration[5.2]
  def change
    add_reference :payments, :cash_flow, index: true, foreign_key: true

    remove_reference :payments, :bank_account, index: true, null: true, foreign_key: true
    remove_reference :payments, :payment_method, index: true, null: true, foreign_key: true
    remove_column :payments, :date, :date
    remove_column :payments, :folio, :string
    remove_column :payments, :charge_id, :string
    remove_column :payments, :concept, :string
    remove_column :payments, :current_term, :integer
    remove_column :payments, :current_discount, :decimal
    remove_column :payments, :is_capital, :boolean
  end
end
