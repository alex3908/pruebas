# frozen_string_literal: true

class AddStatusAndDateToCommissions < ActiveRecord::Migration[5.2]
  def change
    add_column :commissions, :status, :string
    add_column :commissions, :date, :date
  end
end
