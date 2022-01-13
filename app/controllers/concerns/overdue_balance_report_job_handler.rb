# frozen_string_literal: true

module OverdueBalanceReportJobHandler
  extend ActiveSupport::Concern
  def get_overdue_payments(folder)
    count_of_installments_paid = 0
    amount_paid = 0
    date_of_the_last_paid = ""
    count_of_overdue_payments = 0
    overdue_amount = 0
    overdue_amount_down_payment = 0
    capital_amount_overdue = 0
    interest_amount_overdue = 0
    days_expired = 0

    folder.processed_installments.each do |installment|
      pending_payment = 0
      pending_down_payment = 0

      penalty_amount = 0
      total_paid = installment.total_paid
      penalty = installment.penalty
      has_penalty = penalty.present? && penalty_amount.present? && penalty.active
      penalty_amount = penalty&.amount if has_penalty
      total_amount = installment.total + penalty_amount
      total_down_payment = installment.down_payment
      is_paid = total_paid >= total_amount


      if is_paid
        date_of_the_last_paid = installment.date.strftime("%d/%m/%Y")
        count_of_installments_paid += 1
        amount_paid += total_amount
      else
        pending_payment = total_amount - total_paid
        pending_down_payment = total_down_payment - total_paid if total_paid <= total_down_payment
        amount_paid += total_paid
      end

      is_expired = installment.date.to_date < Time.zone.now.to_date && pending_payment > 0

      if is_expired && pending_down_payment > 0
        overdue_amount_down_payment += pending_down_payment
      end

      if is_expired
        days_expired = (Time.zone.now.to_date - installment.date.to_date).to_i if days_expired.zero?

        capital_amount_overdue += installment.capital || 0
        interest_amount_overdue += installment.interest || 0
        count_of_overdue_payments += 1
        overdue_amount += pending_payment
      end
    end

    expired_balance_percentage = (overdue_amount / folder.total_sale) * 100
    active_subscriptions = folder.subscriptions.currently_active
    last_installment_day = folder.financing_installments.last.try(:date)

    {
      amount_paid: amount_paid,
      count_of_installments_paid: count_of_installments_paid,
      date_of_the_last_paid: date_of_the_last_paid,
      count_of_overdue_payments: count_of_overdue_payments,
      overdue_amount: overdue_amount,
      overdue_amount_down_payment: overdue_amount_down_payment,
      capital_interest_amount_overdue: capital_amount_overdue + interest_amount_overdue,
      total_with_discount: folder.total_sale,
      expired_balance_percentage: expired_balance_percentage,
      days_expired: days_expired,
      has_financing_subscription: active_subscriptions.any?(&:finance?),
      has_down_payment_subscription: active_subscriptions.any?(&:balance_down_payment?),
      last_installment_day: last_installment_day
    }
  end
end
