# frozen_string_literal: true

class AddDeleteAtToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :deleted_at, :datetime
  end
end
