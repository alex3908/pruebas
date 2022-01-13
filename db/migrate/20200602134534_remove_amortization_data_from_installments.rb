# frozen_string_literal: true

class RemoveAmortizationDataFromInstallments < ActiveRecord::Migration[5.2]
  def change
    remove_column :installments, :date
    remove_column :installments, :capital
    remove_column :installments, :interest
    remove_column :installments, :down_payment
    remove_column :installments, :total
    remove_column :installments, :debt
  end
end
