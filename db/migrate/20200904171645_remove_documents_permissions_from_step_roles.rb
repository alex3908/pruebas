# frozen_string_literal: true

class RemoveDocumentsPermissionsFromStepRoles < ActiveRecord::Migration[5.2]
  def change
    remove_column :step_roles, :readable_files, :string
    remove_column :step_roles, :uploadable_files, :string
    remove_column :step_roles, :editable_files, :string
    remove_column :step_roles, :destroyable_files, :string
  end
end
