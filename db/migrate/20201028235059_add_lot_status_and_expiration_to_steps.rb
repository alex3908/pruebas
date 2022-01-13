# frozen_string_literal: true

class AddLotStatusAndExpirationToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :lot_status, :integer, default: 1
    add_column :steps, :folders_expires, :boolean, default: false
  end
end
