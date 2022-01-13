# frozen_string_literal: true

class ChangeDefaultValueForPromotions < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:promotions, :start_date, from: DateTime.now, to: -> { "CURRENT_DATE" })
    change_column_default(:promotions, :end_date, from: DateTime.now, to: -> { "CURRENT_DATE" })
  end
end
