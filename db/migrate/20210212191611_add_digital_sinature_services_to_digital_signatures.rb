# frozen_string_literal: true

class AddDigitalSinatureServicesToDigitalSignatures < ActiveRecord::Migration[5.2]
  def change
    add_reference :digital_signatures, :digital_signature_service, foreign_key: true
  end
end
