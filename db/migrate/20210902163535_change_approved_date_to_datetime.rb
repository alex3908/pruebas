# frozen_string_literal: true

class ChangeApprovedDateToDatetime < ActiveRecord::Migration[5.2]
  def change
    change_column :folders, :approved_date, :datetime
  end
end
