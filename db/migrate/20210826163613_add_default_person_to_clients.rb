# frozen_string_literal: true

class AddDefaultPersonToClients < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:clients, :person, from: nil, to: :physical)
  end
end
