# frozen_string_literal: true

class AddStatusToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :status, :string, default: "active"
  end
end
