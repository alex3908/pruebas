# frozen_string_literal: true

class AddErrorDescriptionToDigitalSignatures < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signatures, :error_description, :string
  end
end
