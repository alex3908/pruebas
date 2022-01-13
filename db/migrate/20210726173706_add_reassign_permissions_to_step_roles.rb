# frozen_string_literal: true

class AddReassignPermissionsToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_reassign_client, :boolean, default: false
    add_column :step_roles, :can_reassign_seller, :boolean, default: false
  end
end
