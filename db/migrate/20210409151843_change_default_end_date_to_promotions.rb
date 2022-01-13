# frozen_string_literal: true

class ChangeDefaultEndDateToPromotions < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:promotions, :end_date, true)
    change_column_default(:promotions, :end_date, from: -> { "CURRENT_DATE" }, to: nil)
  end
end
