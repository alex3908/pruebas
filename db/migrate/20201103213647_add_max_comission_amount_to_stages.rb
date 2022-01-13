# frozen_string_literal: true

class AddMaxComissionAmountToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :max_comission_amount, :integer
  end
end
