# frozen_string_literal: true

class AddAmortizationDataToInstallments < ActiveRecord::Migration[5.2]
  def change
    add_column :installments, :date, :date
    add_column :installments, :capital, :decimal
    add_column :installments, :interest, :decimal
    add_column :installments, :down_payment, :decimal
    add_column :installments, :total, :decimal
    add_column :installments, :debt, :decimal
  end
end
