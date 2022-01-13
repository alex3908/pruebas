# frozen_string_literal: true

class AddCanceledAtToCashBack < ActiveRecord::Migration[5.2]
  def change
    add_column :cash_backs, :canceled_at, :datetime, nil: true
  end
end
