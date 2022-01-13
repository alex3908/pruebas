# frozen_string_literal: true

class AddMaxComissionAmountToPaymentSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_schemes, :max_comission_amount, :integer
  end
end
