# frozen_string_literal: true

class ChangeLastFourDigitsToString < ActiveRecord::Migration[5.2]
  def change
    change_column :subscriptions, :last_four_digits, :string
  end
end
