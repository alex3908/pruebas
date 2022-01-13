# frozen_string_literal: true

class AddMaxDelayPaymentsToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :max_delay_payments, :integer, default: 0
  end
end
