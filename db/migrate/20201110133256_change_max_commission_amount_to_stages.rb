# frozen_string_literal: true

class ChangeMaxCommissionAmountToStages < ActiveRecord::Migration[5.2]
  def change
    rename_column :stages, :max_comission_amount, :max_commission_amount
    rename_column :payment_schemes, :max_comission_amount, :max_commission_amount
  end
end
