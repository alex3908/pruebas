# frozen_string_literal: true

class RemoveStepRolesColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :step_roles, :can_send_to_sign_folder_documents
    remove_column :step_roles, :can_send_to_cancel_sign_folder_documents
  end
end
