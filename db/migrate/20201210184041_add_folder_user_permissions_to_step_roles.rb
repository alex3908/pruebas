# frozen_string_literal: true

class AddFolderUserPermissionsToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_add_folder_user, :boolean, default: false
    add_column :step_roles, :can_edit_folder_user, :boolean, default: false
    add_column :step_roles, :can_remove_folder_user, :boolean, default: false
  end
end
