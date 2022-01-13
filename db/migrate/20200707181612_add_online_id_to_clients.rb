# frozen_string_literal: true

class AddOnlineIdToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :online_id, :string
  end
end
