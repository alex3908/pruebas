# frozen_string_literal: true

class AddPlankingAndCadastralFolioToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :planking, :string
    add_column :lots, :folio, :string
    add_column :lots, :number, :integer
    add_column :lots, :label, :string

    rename_column :lots, :depht, :depth
  end
end
