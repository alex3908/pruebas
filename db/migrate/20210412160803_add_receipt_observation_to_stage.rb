# frozen_string_literal: true

class AddReceiptObservationToStage < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :receipt_observations, :text
  end
end
