# frozen_string_literal: true

class CashBackFlow < ApplicationRecord
  belongs_to :cash_back
  belongs_to :cash_flow

  def self.last_balance
    order(created_at: :desc).first.balance_after
  end
end
