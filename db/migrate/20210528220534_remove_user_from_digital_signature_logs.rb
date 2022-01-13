# frozen_string_literal: true

class RemoveUserFromDigitalSignatureLogs < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :digital_signature_logs, :users
  end
end
