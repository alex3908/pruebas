# frozen_string_literal: true

class AddIdentificationTypeToMoralClient < ActiveRecord::Migration[5.2]
  def change
    add_reference :moral_clients, :identification_type, foreign_key: true
    add_reference :moral_clients, :company_identification_type, foreign_key: { to_table: :identification_types }
  end
end
