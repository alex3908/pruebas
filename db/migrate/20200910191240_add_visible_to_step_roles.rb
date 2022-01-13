# frozen_string_literal: true

class AddVisibleToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :visible, :boolean, default: true
  end
end
