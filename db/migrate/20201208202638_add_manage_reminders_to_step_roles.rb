# frozen_string_literal: true

class AddManageRemindersToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_manage_reminders, :boolean, default: false
  end
end
