# frozen_string_literal: true

class AddLastSignInAtToUserClient < ActiveRecord::Migration[5.2]
  def change
    add_column :user_clients, :last_sign_in_at, :datetime
  end
end
