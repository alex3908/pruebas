# frozen_string_literal: true

class MoveDataOfCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    remove_column :credit_schemes, :delivery_date, :date
    remove_column :credit_schemes, :price, :numeric

    add_column :stages, :delivery_date, :date
  end
end
