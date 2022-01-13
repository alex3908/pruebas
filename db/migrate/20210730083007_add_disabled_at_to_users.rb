# frozen_string_literal: true

class AddDisabledAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :activated_at, :datetime
    add_column :users, :disabled_at, :datetime
  end
end
