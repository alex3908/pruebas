# frozen_string_literal: true

class AddLeadSourceToClient < ActiveRecord::Migration[5.2]
  def change
    add_reference :clients, :lead_source, index: true, foreign_key: true,
      on_delete: :restrict
  end
end
