# frozen_string_literal: true

class DestroyEvoTables < ActiveRecord::Migration[5.2]
  def change
    drop_table :salesmen
    drop_table :coordinators
    drop_table :managers
    drop_table :vice_directors
    drop_table :directors
  end
end
