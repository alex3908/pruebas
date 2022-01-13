# frozen_string_literal: true

class AddIsRelativeFinancingToCreditScheme < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :is_relative_financing, :boolean, default: false
  end
end
