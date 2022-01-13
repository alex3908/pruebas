# frozen_string_literal: true

class AddSignlinksToStepRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :step_roles, :show_clients_signature_links, :boolean, default: false
    add_column :step_roles, :show_signers_signature_links, :boolean, default: false
    add_column :step_roles, :can_send_signature_link_by_whatsapp, :boolean, default: false
    add_column :step_roles, :can_send_signature_link_by_email, :boolean, default: false
    add_column :step_roles, :can_send_signature_link_by_clipboard, :boolean, default: false
  end
end
