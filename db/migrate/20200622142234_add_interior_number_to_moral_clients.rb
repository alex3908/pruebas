# frozen_string_literal: true

class AddInteriorNumberToMoralClients < ActiveRecord::Migration[5.2]
  def change
    add_column :moral_clients, :interior_number, :string, after: :house_number
  end
end
