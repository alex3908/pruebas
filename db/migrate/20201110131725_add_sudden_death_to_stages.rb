# frozen_string_literal: true

class AddSuddenDeathToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :sudden_death, :integer
    add_column :folders, :initial_payment_sudden_death, :integer
    add_column :folders, :down_payment_sudden_death, :integer
  end
end
