# frozen_string_literal: true

class AddDateToDigitalSignatureServices < ActiveRecord::Migration[5.2]
  def change
    add_column :digital_signatures, :date, :datetime
  end
end
