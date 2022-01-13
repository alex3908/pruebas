# frozen_string_literal: true

class AddCompoundInterestToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :compound_interest, :boolean, default: true
  end
end
