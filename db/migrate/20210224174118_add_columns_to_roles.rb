# frozen_string_literal: true

class AddColumnsToRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :sale_commission, :float, default: 0
    add_column :roles, :maximum_schemes, :integer, default: 0
    add_column :roles, :commission_monitoring, :float, default: 0
  end
end
