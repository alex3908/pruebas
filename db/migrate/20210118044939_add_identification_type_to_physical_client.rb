# frozen_string_literal: true

class AddIdentificationTypeToPhysicalClient < ActiveRecord::Migration[5.2]
  def change
    add_reference :physical_clients, :identification_type, foreign_key: true
  end
end
