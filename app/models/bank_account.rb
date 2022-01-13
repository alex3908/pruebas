# frozen_string_literal: true

class BankAccount < ApplicationRecord
  scope :only_active, -> { where(active: true)  }
  has_many :cash_flows
  belongs_to :payable, polymorphic: true

  before_save :set_default_principal, :set_new_principal
  before_update :set_new_principal

  def set_default_principal
    self.principal = true if self.payable_type == "User" && self.payable.bank_accounts.count <= 0
  end

  def set_new_principal
    bank_accounts = self.payable.bank_accounts
    if self.principal? && bank_accounts.size > 1
      account = bank_accounts.find_by(principal: true)
      account.update(principal: false) if account.present?
    end
  end
end
