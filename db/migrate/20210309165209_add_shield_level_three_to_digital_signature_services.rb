class AddShieldLevelThreeToDigitalSignatureServices < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signature_services, :is_shield_level_three_clients, :boolean, default:false
    add_column :digital_signature_services, :is_shield_level_three_signers, :boolean, default:false
    add_column :digital_signature_services, :shield_level_three_message, :string
  end
end
