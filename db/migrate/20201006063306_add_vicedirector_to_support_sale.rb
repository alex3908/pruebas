# frozen_string_literal: true

class AddVicedirectorToSupportSale < ActiveRecord::Migration[5.2]
  def change
    add_reference :support_sales, :support_vicedirector, index: true, null: true, foreign_key: { to_table: "users" }
  end
end
