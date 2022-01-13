# frozen_string_literal: true

class AddCanceledDateToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :cancelation_date, :datetime
    add_column :payments, :cancelation_description, :string
  end
end
