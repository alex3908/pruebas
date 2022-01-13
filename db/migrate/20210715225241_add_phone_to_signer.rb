# frozen_string_literal: true

class AddPhoneToSigner < ActiveRecord::Migration[5.2]
  def change
    add_column :signers, :phone, :string
  end
end
