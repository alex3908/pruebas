# frozen_string_literal: true

class AddPermissionsToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :send_by_whatsapp, :boolean, default: false
    add_column :step_roles, :send_by_email, :boolean, default: false
    add_column :step_roles, :copy_to_clipboard, :boolean, default: false
  end
end
