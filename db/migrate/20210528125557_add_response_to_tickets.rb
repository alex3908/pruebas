# frozen_string_literal: true

class AddResponseToTickets < ActiveRecord::Migration[5.2]
  def change
    add_column :online_payment_tickets, :response, :json
    add_column :online_payment_tickets, :webhook, :boolean, default: false
  end
end
