# frozen_string_literal: true

class AddActiveAnnexePldToContract < ActiveRecord::Migration[5.2]
  def change
    add_column :contracts, :active_annexe_pld, :boolean, default: false
  end
end
