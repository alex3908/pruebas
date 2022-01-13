# frozen_string_literal: true

class AddPasswordDigestToUserClient < ActiveRecord::Migration[5.2]
  def change
    add_column :user_clients, :password_digest, :string
    add_column :user_clients, :client_id, :integer
  end
end
