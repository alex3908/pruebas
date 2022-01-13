# frozen_string_literal: true

class AddColumnsToDigitalSignatures < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signatures, :sent_to_clients, :boolean, default: false
    add_column :digital_signatures, :sent_to_representatives, :boolean, default: false
  end
end
