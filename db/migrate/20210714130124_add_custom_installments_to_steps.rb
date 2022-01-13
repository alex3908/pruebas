# frozen_string_literal: true

class AddCustomInstallmentsToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_manage_custom_installments, :boolean, default: false
  end
end
