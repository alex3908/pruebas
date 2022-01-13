# frozen_string_literal: true

class RemoveForeginKeysFromTables < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :api_keys, :users
    remove_foreign_key :cash_backs, :users
    remove_foreign_key :cash_flows, :users
    remove_foreign_key :clients, :users
    remove_foreign_key :comments, :users
    remove_foreign_key :evaluation_folders, :users
    remove_foreign_key :file_approvals, column: :approved_by_id
    remove_foreign_key :folder_users, :users
    remove_foreign_key :folders, :users
    remove_foreign_key :folders, column: :canceled_by
    remove_foreign_key :job_statuses, :users
    remove_foreign_key :payments, :users
    remove_foreign_key :penalties, column: :canceled_by
    remove_foreign_key :project_users, :users
    remove_foreign_key :quote_logs, :users
    remove_foreign_key :referents, column: :invited_id
    remove_foreign_key :referents, column: :referrer_id
    remove_foreign_key :stage_users, :users
    remove_foreign_key :step_logs, :users
    remove_foreign_key :structures, :users
    remove_foreign_key :support_sales, column: :requester_id
    remove_foreign_key :support_sales, column: :support_coordinator_id
    remove_foreign_key :support_sales, column: :support_manager_id
    remove_foreign_key :support_sales, column: :support_vicedirector_id
    remove_foreign_key :support_sales, column: :supporter_id
  end
end
