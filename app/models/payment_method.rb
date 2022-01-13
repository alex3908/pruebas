# frozen_string_literal: true

class PaymentMethod < ApplicationRecord
  acts_as_paranoid

  has_many :cash_backs
  has_many :credit_schemes
  scope :visible, -> () { where(active: true) }
  scope :with_cash_back, -> () { visible.where(cash_back: true, add_balance: true) }
  scope :for_referred, -> { where(reffered_client_cash_back: true) }

  def select_label
    if cash_back_folder_exclusivity?
      return name + " (Restringido a expediente)"
    end

    name
  end
end
