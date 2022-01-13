# frozen_string_literal: true

class RemoveStartDateFromCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    remove_column :credit_schemes, :start_date_by
    remove_column :credit_schemes, :formula
    remove_column :stages, :formula
    change_column :credit_schemes, :second_payment, :integer
    change_column_default :credit_schemes, :initial_payment, 0
    change_column_default :stages, :start_date_by, "stage_date"
  end
end
