# frozen_string_literal: true

class AddIsCustomToInstallments < ActiveRecord::Migration[5.2]
  def change
    add_column :installments, :is_custom, :boolean, default: false
  end
end
