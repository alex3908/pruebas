# frozen_string_literal: true

class AddCashBackFolderExclusivityToPaymentMethods < ActiveRecord::Migration[5.2]
  def change
    add_column :payment_methods, :cash_back_folder_exclusivity, :boolean
  end
end
