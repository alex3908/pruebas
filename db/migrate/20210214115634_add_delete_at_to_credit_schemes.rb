# frozen_string_literal: true

class AddDeleteAtToCreditSchemes < ActiveRecord::Migration[5.2]
  def change
    add_column :credit_schemes, :deleted_at, :datetime
  end
end
