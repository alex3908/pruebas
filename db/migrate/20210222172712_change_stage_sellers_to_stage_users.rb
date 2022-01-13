# frozen_string_literal: true

class ChangeStageSellersToStageUsers < ActiveRecord::Migration[5.2]
  def change
    rename_table :stage_sellers, :stage_users
  end
end
