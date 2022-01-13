# frozen_string_literal: true

class RemovePenaltyUserForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :penalties, :users
  end
end
