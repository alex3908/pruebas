# frozen_string_literal: true

module CustomInstallmentsHelper
  def process_periods(credit_scheme_periods)
    periods = []
    initial_payment = 0
    credit_scheme_periods.each do |period, index|
      final_payment = initial_payment + period.payments
      periods << { initial_payment: initial_payment, final_payment: final_payment, interest: period.interest, payments: period.payments }
      initial_payment = final_payment
    end
    periods
  end

  def validate_relative_months(credit_scheme, stage)
    periods = []
    expired_months = 0
    credit_scheme_periods = credit_scheme.periods.order(order: :asc)
    if credit_scheme.expire_months
      today = Time.zone.now
      expired_months = ((today.year * 12 + today.month) - (stage.release_date.year * 12 + stage.release_date.month))
    end

    more_than_one_period = credit_scheme_periods.size > 1
    credit_scheme_periods.each_with_index do |period, index|
      if more_than_one_period
        if index == 0
          payments = period.payments - expired_months
          if payments < 0
            expired_months = period.payments
            period.payments = 0
          else
            period.payments = payments
          end
        elsif index == 1
          period.payments = period.payments + expired_months
        end
      end
      periods << period
    end
    periods
  end

  def calculate_installments(installments, folder, total_sale)
    total_sale = total_sale.round(2)
    credit_scheme = folder.payment_scheme.credit_scheme
    credit_scheme_periods = validate_relative_months(credit_scheme, folder.lot.stage)
    periods = process_periods(credit_scheme_periods)
    installments.each do |installment|
      if !total_sale.zero?
        interest = 0
        period_with_interest = periods.select { |period|  installment.number.to_i > period[:initial_payment] && installment.number.to_i <= period[:final_payment] }.first
        if period_with_interest.present? && installment.capital > 0
          percentage = period_with_interest[:interest].to_d / 100
          interest = (total_sale.to_d * percentage).round(2)
        end
        installment.capital = total_sale if installment.capital > total_sale
        installment.total = installment.capital.round(2) + interest
        installment.interest = interest
        installment.debt = (total_sale.to_d - installment.capital.to_d).round(2)
        total_sale = installment.debt
      else
        installment.capital = 0
        installment.total = 0
        installment.interest = 0
        installment.debt = 0
      end
    end
  end
end
