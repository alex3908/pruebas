# frozen_string_literal: true

class AddActiveMailsToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :active_mails, :boolean, default: true
  end
end
