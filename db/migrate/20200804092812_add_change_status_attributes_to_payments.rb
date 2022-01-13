# frozen_string_literal: true

class AddChangeStatusAttributesToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :deleted_at, :datetime
    add_column :payments, :canceled_by, :integer
  end
end
