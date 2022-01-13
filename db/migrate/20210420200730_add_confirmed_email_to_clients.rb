# frozen_string_literal: true

class AddConfirmedEmailToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :confirmed_email, :boolean, default: false
  end
end
