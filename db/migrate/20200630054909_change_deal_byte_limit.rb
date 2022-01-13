# frozen_string_literal: true

class ChangeDealByteLimit < ActiveRecord::Migration[5.2]
  def change
    change_column :folders, :deal, :integer, limit: 8
  end
end
