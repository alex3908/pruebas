# frozen_string_literal: true

class AddActiveCommissionsToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :active_commissions, :boolean, default: true
  end
end
