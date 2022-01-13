# frozen_string_literal: true

class AddDeleteAtToDigitalSignatureServices < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signature_services, :deleted_at, :datetime
    add_index :digital_signature_services, :deleted_at
  end
end
