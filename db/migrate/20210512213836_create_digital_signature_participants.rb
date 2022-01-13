# frozen_string_literal: true

class CreateDigitalSignatureParticipants < ActiveRecord::Migration[5.2]
  def change
    create_table :digital_signature_participants do |t|
      t.references :digital_signature, index: true, foreign_key: true
      t.string :participant_id
      t.string :email
      t.string :sign_url
      t.string :status
      t.string :recipient_type
      t.boolean :email_send, default: false
      t.timestamps
    end
  end
end
