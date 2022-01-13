# frozen_string_literal: true

class AddFitSignatureToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :fit_signature, :boolean, default: :false
  end
end
