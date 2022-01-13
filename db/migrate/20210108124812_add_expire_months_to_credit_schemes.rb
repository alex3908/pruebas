# frozen_string_literal: true

class AddExpireMonthsToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :expire_months, :boolean, default: true
  end
end
