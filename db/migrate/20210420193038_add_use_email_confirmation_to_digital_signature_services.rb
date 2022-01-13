# frozen_string_literal: true

class AddUseEmailConfirmationToDigitalSignatureServices < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signature_services, :use_email_confirmation, :boolean, default: false
  end
end
