# frozen_string_literal: true

class AddInstallmentToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :installments_step, :boolean, default: false
  end
end
