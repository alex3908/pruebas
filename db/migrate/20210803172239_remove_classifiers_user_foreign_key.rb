# frozen_string_literal: true

class RemoveClassifiersUserForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :classifiers_users, :users
  end
end
