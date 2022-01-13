# frozen_string_literal: true

class AddCanMakeInstallmentToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_make_installments, :boolean, default: false
  end
end
