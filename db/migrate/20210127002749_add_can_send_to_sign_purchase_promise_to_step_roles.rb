# frozen_string_literal: true

class AddCanSendToSignPurchasePromiseToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :can_send_to_sign_purchase_promise, :boolean, default: false
    add_column :step_roles, :can_send_to_cancel_sign_purchase_promise, :boolean, default: false
    add_column :step_roles, :can_send_to_sign_folder_documents, :boolean, default: false
    add_column :step_roles, :can_send_to_cancel_sign_folder_documents, :boolean, default: false
    add_column :step_roles, :can_resend_sign_files, :boolean, default: false
  end
end
