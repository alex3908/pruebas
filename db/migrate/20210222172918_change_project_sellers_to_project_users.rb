# frozen_string_literal: true

class ChangeProjectSellersToProjectUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :project_sellers, :project_users
  end
end
