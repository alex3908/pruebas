# frozen_string_literal: true

class AddCustomizationToProjectsQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :show_amortization_table, :bool, default: false
    add_column :projects, :show_rate, :bool, default: false
    add_column :projects, :show_price, :bool, default: false
    add_column :projects, :show_bank_account, :bool, default: false
  end
end
