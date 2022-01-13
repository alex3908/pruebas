# frozen_string_literal: true

class AddOptionsToDigitalSignatureService < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signature_services, :jump_to_step, :boolean, default: false
    add_column :digital_signature_services, :jump_step_id, :integer
  end
end
