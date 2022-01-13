# frozen_string_literal: true

class Subscription < ApplicationRecord
  STATUS = { ACTIVE: "A", CANCELED: "C" }

  scope :currently_active, ->() { where(status: "A") }

  CONCEPT_KEYS = I18n.t("activerecord.attributes.subscription.concept_keys")
  enum concept_key: HashWithIndifferentAccess.new(finance: "finance", balance_down_payment: "balance_down_payment")
  enum status: HashWithIndifferentAccess.new(active: "A", canceled: "C")

  belongs_to :folder
  belongs_to :client
  belongs_to :online_payment_service, optional: true
  has_many :subscription_plans

  attr_accessor :concept
  attr_accessor :amount
  attr_accessor :months_to_subscribe

  def active_subscription_plan
    subscription_plans.where("DATE(?) BETWEEN start_date AND end_date", Time.zone.now).take
  end

  def status_label
    self.active? ? "Activo" : "Cancelado"
  end

  def total_payments_count
    subscription_plans.sum(:payments_count)
  end

  def card_updatable?
    allow_update || card_soon_to_expire?
  end

  def card_soon_to_expire?
    exp_year <= Time.zone.now.strftime("%y").to_i && exp_month <= Time.zone.now.next_month.strftime("%m").to_i
  end

  def update_netpay_plan
    plan = active_subscription_plan

    online_payment_service.plan_manager.update_plan_amount(online_plan_id, plan.amount, "#{SubscriptionPlan.human_attribute_name(plan.concept_description)} expediente #{folder.id}-#{Time.zone.now.to_i}")
  end
end
