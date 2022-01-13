# frozen_string_literal: true

class AddCanceledDescriptionToCashFlows < ActiveRecord::Migration[5.2]
  def change
    add_column :cash_flows, :cancelation_description, :string
  end
end
