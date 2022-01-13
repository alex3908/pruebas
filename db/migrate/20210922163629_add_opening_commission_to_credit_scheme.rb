# frozen_string_literal: true

class AddOpeningCommissionToCreditScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :is_opening_commission, :boolean, default: false
    add_column :credit_schemes, :opening_commission, :decimal, default: 0
  end
end
