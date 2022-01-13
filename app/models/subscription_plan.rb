# frozen_string_literal: true

class SubscriptionPlan < ApplicationRecord
  belongs_to :subscription

  enum concept_description: { financing: "financing", down_payment: "down_payment", initial_payment: "initial_payment" }

  validates :payments_count, numericality: { greater_than: 0 }


  def paid_installment_ids
    subscription.folder.installments.group_by(&:total).fetch(amount, []).select(&:is_paid?).map(&:id)
  end

  def plan_complete?
    payments_count == paid_installment_ids.size
  end

  private

    def update_subscription_amount
      subscription.update_netpay_plan
    end
end
