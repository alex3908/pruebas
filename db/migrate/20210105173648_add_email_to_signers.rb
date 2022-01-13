# frozen_string_literal: true

class AddEmailToSigners < ActiveRecord::Migration[5.2]
  def change
    add_column :signers, :email, :string, after: :company
    add_column :signers, :first_surname, :string, after: :name
    add_column :signers, :second_surname, :string, after: :first_surname
  end
end
