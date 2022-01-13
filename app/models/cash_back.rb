# frozen_string_literal: true

class CashBack < ApplicationRecord
  STATUS = { ACTIVE: "active", CANCELED: "canceled" }
  enum status: { active: "active", canceled: "canceled" }

  attr_accessor :leftover_amount

  belongs_to :exclusive_folder, class_name: "Folder", foreign_key: "exclusive_folder_id", optional: true
  belongs_to :client
  belongs_to :user
  belongs_to :canceled_by, class_name: "User", foreign_key: "canceled_by", required: false
  belongs_to :payment_method, with_deleted: true

  has_many :cash_back_flows

  before_create :set_defaults

  def last_balance
    return amount if cash_back_flows.empty?

    cash_back_flows.last_balance
  end

  def set_defaults
    self.status = CashFlow::STATUS[:ACTIVE]
  end

  def status_label
    statuses = {
        STATUS[:ACTIVE] => "Activo",
        STATUS[:CANCELED] => "Cancelado",
    }
    statuses[self.status]
  end
end
