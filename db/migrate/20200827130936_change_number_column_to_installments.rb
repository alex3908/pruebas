# frozen_string_literal: true

class ChangeNumberColumnToInstallments < ActiveRecord::Migration[5.2]
  def up
    change_column :installments, :number, :string
  end

  def down
    change_column :installments, :number, "integer USING CAST(number AS integer)"
  end
end
