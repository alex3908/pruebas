# frozen_string_literal: true

class ChangeBaseCommissionReferenceToFolderUser < ActiveRecord::Migration[5.2]
  def change
    rename_column :commissions, :base_commission_id, :folder_user_id
  end
end
