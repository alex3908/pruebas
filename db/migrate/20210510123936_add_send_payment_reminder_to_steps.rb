# frozen_string_literal: true

class AddSendPaymentReminderToSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :send_payment_reminder, :boolean, default: false
  end
end
