# frozen_string_literal: true

class AddEmailPaymentReceptorsToStages < ActiveRecord::Migration[5.2]
  def change
    add_column :stages, :payment_receptor_emails, :string, array: true
  end
end
