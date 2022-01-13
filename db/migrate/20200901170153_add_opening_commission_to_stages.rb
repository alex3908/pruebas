# frozen_string_literal: true

class AddOpeningCommissionToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :opening_commission, :decimal
  end
end
