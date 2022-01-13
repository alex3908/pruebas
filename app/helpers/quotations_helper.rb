# frozen_string_literal: true

module QuotationsHelper
  include DiscountsHelper, PaymentsHelper, PromotionHandler

  def generate_amortization(price:, area:, start_date:, date:, total_payments:, down_payment_total_payments:, discount:, buy_price:, initial_payment:, down_payment:, first_payment: 0, zero_rate: nil, capital_payments: [], exclusive_promotion: 0, exclusive_promotion_operation: nil, promotion: 0, promotion_operation: nil, coupon: 0, coupon_operation: nil, start_installments: nil, zero_rate_extra: 0, credit_scheme: [], project_type:, complement_payment: 0, immediate_extra_months: 0, dfp: nil, expire_months: true, relative_discount: true, with_amortization: true, relative_down_payment: false, independent_initial_payment: false, delivery_date: nil, second_payment: 0, initial_payment_active: true, consider_residue_in_down_payments: false, quotation_type: CreditScheme.quotation_types[:multiple_periods], with_last_payment: false, last_payment_amount: 0, is_relative_financing: false)
    down_payment_unique_payments = start_installments if start_installments.present? && (down_payment_total_payments > start_installments)
    credit_scheme = validate_credit(credit_scheme)

    case quotation_type
    when CreditScheme.quotation_types[:multiple_periods]
      use_compound_interest = true
    when CreditScheme.quotation_types[:simple_interest]
      use_compound_interest = false
      buy_price = calculate_buy_price_with_periods(total_payments, buy_price, credit_scheme, zero_rate_extra)
      price = area * buy_price
      credit_scheme = credit_scheme.each { |period| period.interest = 0 }
    else
      use_compound_interest = false
    end

    start_installments ||= down_payment_total_payments
    down_payment_unique_payments ||= down_payment_total_payments
    complement_payment ||= 0
    first_period_payments = credit_scheme.first.payments
    second_period_payments = first_period_payments + credit_scheme.second.payments
    third_period_payments = second_period_payments + credit_scheme.third.payments
    total_periods = credit_scheme.inject(0) { |sum, period| sum + period.payments }
    total = buy_price * area
    payment_plan_name = (total_payments == 1) ? "Contado" : "#{total_payments} meses"
    promo = promotion_calculator(total, discount, exclusive_promotion, exclusive_promotion_operation, promotion, promotion_operation, coupon, coupon_operation)
    down_payment_added = down_payment_unique_payments
    down_payment_monthly_payments = Array.new
    amr = Array.new
    down_payments = Array.new
    only_down_payments = Array.new
    first_payment_advance = date.next_day(first_payment)
    first_payment_down_payment = date.next_day(second_payment)

    if initial_payment_active && second_payment < first_payment
      first_payment_down_payment = first_payment_advance
    end

    down_payment_total = down_payment < 1 ? promo.total * down_payment : down_payment

    if initial_payment_active && independent_initial_payment
      down_payment_to_differ = down_payment_total - initial_payment
    else
      down_payment_to_differ = down_payment_total
    end

    first_finance_payment = first_payment_down_payment.next_month(start_installments - 1)
    total_minus_down_payment = promo.total - down_payment_total
    total_minus_down_payment -= last_payment_amount if with_last_payment

    amr_calc = total_minus_down_payment

    down_payment_calc = down_payment_to_differ
    price_with_interest = promo.total
    if project_type == "new"
      if zero_rate.present?
        first_period_payments = zero_rate
      else
        if start_date.present? && expire_months
          end_date = start_date + first_period_payments.months
          first_period_payments = (end_date.year * 12 + end_date.month) - (date.year * 12 + date.month)
        end
      end
    end

    first_period_payments += zero_rate_extra + immediate_extra_months

    if dfp.present?
      initial_periods = dfp_calculation(
        payments: total_payments,
        balance: total_minus_down_payment,
        dfp: dfp,
        first_period_payments: first_period_payments,
        second_period_payments: second_period_payments
      )
    else
      initial_periods = period_calculation(
        payments: total_payments,
        balance: total_minus_down_payment,
        first_period_payments: first_period_payments,
        second_period_payments: second_period_payments,
        credit_scheme: credit_scheme,
        use_compound_interest: use_compound_interest,
      )
    end

    quotation_with_capital_payment = false
    down_payment_monthly_payment = period_calculation(
      payments: down_payment_total_payments,
      balance: down_payment_to_differ,
      credit_scheme: credit_scheme,
      down_payment: true
    )

    if initial_payment_active
      down_payment_monthly_payments << {
        concept: Installment::CONCEPT[:INITIAL_PAYMENT],
        down_payment: initial_payment,
        payment: initial_payment,
        date: first_payment_advance,
        number: "A",
        total_payments: down_payment_total_payments
      }

      down_payments << {
        concept: "Apartado",
        payment: initial_payment,
        total_payments: 1
      }
    end

    payment_capital_was_calculated = false
    down_payment_periods = 0
    (1..down_payment_total_payments).each_with_index do |payment_number, index|
      if independent_initial_payment || !initial_payment_active || index > 0
        payment = down_payment_monthly_payment.first[:amount]
      else
        payment = down_payment_monthly_payment.first[:amount] - initial_payment
      end

      down_payment_capital_payments = process_down_payment_capital_payments(capital_payments, payment_number, payment, credit_scheme, down_payment_calc, quotation_with_capital_payment, down_payment_monthly_payment, first_payment_down_payment)

      down_payment_calc = down_payment_capital_payments[:down_payment_calc]
      quotation_with_capital_payment = down_payment_capital_payments[:quotation_with_capital_payment]
      down_payment_monthly_payment = down_payment_capital_payments[:down_payment_monthly_payment]
      payment = down_payment_capital_payments[:payment]
      first_payment_down_payment = down_payment_capital_payments[:first_payment_down_payment]
      down_payment_calc = down_payment_calc - payment

      if capital_payments.length > 0
        if down_payment_calc <= 0
          if payment_capital_was_calculated
            break
          else
            payment_capital_was_calculated = true
            payment = down_payment_monthly_payments.last.present? ? down_payment_calc + payment : 0
            down_payment_calc = 0
          end
        end
      end

      break if (payment.round(2) < 0) || (down_payment_calc.round(2) < 0)

      down_payment_hash = {
        concept: Installment::CONCEPT[:DOWN_PAYMENT],
        down_payment: payment,
        payment: payment,
        date: first_payment_down_payment.next_month(payment_number - 1),
        number: payment_number,
        total_payments: down_payment_total_payments
      }

      only_down_payments << down_payment_hash
      down_payment_monthly_payments << down_payment_hash
    end

    if down_payment_monthly_payments.any? && consider_residue_in_down_payments
      reference_total = down_payment_to_differ
      reference_total -= initial_payment if !initial_payment_active && !independent_initial_payment

      if only_down_payments.any?
        down_payment_residue = reference_total - only_down_payments.inject(0) { |sum, normal_payment| sum + normal_payment[:payment].round(2) }

        if !down_payment_residue.zero?
          down_payment_index = down_payment_monthly_payments.index(only_down_payments.first)
          down_payment_with_residue = down_payment_monthly_payments[down_payment_index][:payment] + down_payment_residue
          down_payment_monthly_payments[down_payment_index][:down_payment] = down_payment_monthly_payments[down_payment_index][:payment] = down_payment_with_residue
        end
      end
    end

    down_payment_monthly_payments.each do |down_payment_hash|
      next if down_payment_hash[:concept] == Installment::CONCEPT[:INITIAL_PAYMENT]
      actual_down_payment = down_payments.find { |element| element[:payment] == down_payment_hash[:payment] }
      down_payment_index = down_payments.index(actual_down_payment)
      if actual_down_payment.present?
        down_payments[down_payment_index][:total_payments] += 1
      else
        down_payments << {
          concept: "Enganche #{down_payment_periods += 1}",
          payment: down_payment_hash[:payment],
          total_payments: 1
        }
      end
    end

    grace_month = 0
    delay_hash = {
        delay_months: 0,
        delay_payment: 0,
        delay_interest: 0,
        delay_type: "",
        delay_array: [],
        delay_last: 0,
    }

    payment_capital_was_calculated = false
    periods = initial_periods
    fourth_period_calculated = false
    payment_number = 0
    index = 0
    actual_day = first_finance_payment.day
    amr_calc_with_restructure = 0

    if with_amortization
      loop do
        payment_number += 1
        capital_amount = 0
        amr_calc_extra = 0

        selected_period = select_current_period(
          payment_number: payment_number,
          first_period_payments: first_period_payments,
          second_period_payments: second_period_payments,
          third_period_payments: third_period_payments,
          periods: periods,
          total_payments: total_payments,
          total_periods: total_periods,
          delay_hash: delay_hash,
          amr_calc: amr_calc,
          fourth_period_calculated: fourth_period_calculated
        )

        current_period = selected_period[:current_period]
        fourth_period_calculated = selected_period[:fourth_period_calculated]
        first_period = selected_period[:first_period]
        second_period = selected_period[:second_period]
        current_period ||= periods.last
        interest = amr_calc * current_period[:rate]
        payment = current_period[:amount]

        if capital_payments.length > 0

          capital_payments_result = process_capital_payments(capital_payments, buy_price, area, discount, delay_hash, payment_number, amr_calc, total_payments, first_period_payments, first_period, second_period, credit_scheme, second_period_payments, third_period_payments, total_periods, fourth_period_calculated, interest, dfp, periods, payment, quotation_with_capital_payment, actual_day, grace_month, use_compound_interest, amr_calc_extra, total, promo)

          periods = capital_payments_result[:periods]
          delay_hash = capital_payments_result[:delay_hash]
          amr_calc = capital_payments_result[:amr_calc]
          payment = capital_payments_result[:payment]
          interest = capital_payments_result[:interest]
          quotation_with_capital_payment = capital_payments_result[:quotation_with_capital_payment]
          grace_month = capital_payments_result[:grace_month]
          actual_day = capital_payments_result[:actual_day]
          amr_calc_with_restructure += capital_payments_result[:amr_calc_extra]
          discount = capital_payments_result[:discount]
          promo = capital_payments_result[:promo]
        end

        if delay_hash[:delay_months] > 0 && delay_hash[:delay_type] == Restructure::CONCEPT[:DELAY_IMMEDIATE]
          delay_hash[:delay_payment] += payment
          delay_hash[:delay_interest] += interest
        elsif delay_hash[:delay_months] > 0 && delay_hash[:delay_type] == Restructure::CONCEPT[:DELAY_ALTERNATE]
          delay_hash[:delay_array] << { payment: payment, interest: interest }
        elsif delay_hash[:delay_months] > 0 && delay_hash[:delay_type] == Restructure::CONCEPT[:DELAY_LAST]
          delay_hash[:delay_last] += 1
        else
          if delay_hash[:delay_type] == Restructure::CONCEPT[:DELAY_IMMEDIATE]
            payment += delay_hash[:delay_payment]
            interest += delay_hash[:delay_interest]
            delay_hash[:delay_payment] = 0
            delay_hash[:delay_interest] = 0
          end

          if delay_hash[:delay_array].length > 0 && delay_hash[:delay_type] == Restructure::CONCEPT[:DELAY_ALTERNATE]
            payment += delay_hash[:delay_array].first[:payment]
            interest += delay_hash[:delay_array].first[:interest]
            delay_hash[:delay_array].shift
          end

          amr_calc = amr_calc - (payment - interest)
          price_with_interest += payment + interest
        end

        if delay_hash[:delay_months] > 0 && Restructure.delay_concept?(delay_hash[:delay_type])
          payment = 0
          interest = 0
          delay_hash[:delay_months] -= 1
        end

        if capital_payments.length > 0
          if amr_calc <= 0
            if payment_capital_was_calculated
              break
            else
              payment_capital_was_calculated = true
              amr_calc = 0
              payment = amr.last.present? ? amr.last[:amount].to_f + interest.to_f : payment + interest
            end
          end
        end

        if relative_down_payment && delivery_date.present? && !is_relative_financing
          actual_date = delivery_date.next_month(index + grace_month)
        else
          actual_date = first_finance_payment.next_month(payment_number + grace_month)
        end

        days_in_current_month = Time.days_in_month(actual_date.month, actual_date.year)
        relative_day = actual_day > days_in_current_month ? days_in_current_month : actual_day
        actual_date = actual_date.change({ day: relative_day })

        down_payment_finance = down_payment_monthly_payments.find { |down_payment_monthly| down_payment_monthly[:date].next_month(grace_month).strftime("%m/%Y") == actual_date.strftime("%m/%Y") }
        if down_payment_finance.present?
          down_payment_monthly_payments.delete(down_payment_finance)
          down_payment_finance = down_payment_finance[:payment].to_f
          total_payment = payment + down_payment_finance
          down_payment_finance
        else
          down_payment_finance = 0
          total_payment = payment
        end

        break if amr_calc.round(2) < 0 || (payment - interest).round(2) < 0 || (total_payment.round(2) <= 0 && amr_calc.round(2) <= 0) || payment_number > 300

        amr << {
          date: actual_date,
          number: payment_number,
          interest: interest,
          down_payment: down_payment_finance,
          capital: (payment - interest),
          capital_payment: capital_amount,
          concept: Installment::CONCEPT[:FINANCING],
          payment: total_payment,
          amount: "%.2f" % amr_calc
        }

        down_payment_added += 1
        index += 1
      end
    end

    amr = validate_amortization(first_finance_payment, amr)
    last_amr = amr.last

    if with_last_payment && with_amortization
      last_payment_date = is_relative_financing && delivery_date.present? ? delivery_date : last_amr[:date].to_date.next_month(1)
      amr << add_last_payment(last_payment_date, last_payment_amount)
    end

    interest_free_period = periods.select { |period| period[:rate] == 0 }.first
    interest_free_period = interest_free_period.nil? ? 0 : interest_free_period[:payments]

    Quotation.new(
      plan_name: payment_plan_name,
      total_payments: total_payments,
      price: price,
      total_price: promo.total,
      price_with_interest: price_with_interest,
      initial_payment: initial_payment,
      down_payment: down_payment,
      down_payment_finance: down_payment_total_payments,
      is_down_payment_differ: (start_installments.present? && (down_payment_total_payments - down_payment_unique_payments > 0)),
      down_payment_monthly_payment: down_payment_monthly_payment.first[:amount],
      down_payment_to_differ: down_payment_to_differ,
      down_payment_first_pay_date: first_payment_down_payment.strftime("%d/%m/%Y"),
      payments: last_amr.present? ? last_amr[:number] : nil,
      discount: promo.discount,
      saving: promo.savings,
      total_minus_down_payment: total_minus_down_payment,
      total: total,
      total_with_discount: (promo.total + amr_calc_with_restructure).truncate(2),
      total_discount: promo.discount,
      down_payment_total: down_payment_total,
      interest_payments: periods,
      interest_free_period: interest_free_period,
      down_payment_percentage: "%.2f" % (down_payment_total * 100 / promo.total),
      down_payment_monthly_payments: down_payment_monthly_payments,
      amr: amr,
      have_capital_payment: quotation_with_capital_payment,
      initial_periods: initial_periods,
      complement_payment: complement_payment,
      down_payments: down_payments,
      last_payment: last_payment_amount,
      last_payment_percentage: "%.2f" % (last_payment_amount * 100 / (promo.total + amr_calc_with_restructure))
    )
  end

  def validate_amortization(first_finance_payment, amr)
    if amr.empty?
      amr << {
        date: first_finance_payment.next_month(1),
        number: 1,
        interest: 0,
        down_payment: 0,
        capital: 0,
        capital_payment: 0,
        concept: Installment::CONCEPT[:FINANCING],
        payment: 0,
        amount: 0
      }
    else
      amr
    end
  end

  def get_relative_plans(lot)
    relative_discounts = []
    relative_plans = Discount.where("is_active = (?) AND credit_scheme_id = (?)", true, lot.stage.credit_scheme_id).order(total_payments: :desc)
    periods = lot.stage.credit_scheme.periods.order(order: :ASC)
    total_periods_payments = periods.inject(0) { |sum, period| sum + period.payments }

    if lot.stage.credit_scheme.relative_discount
      today = Time.zone.now
      expired_months = (today.year * 12 + today.month) - (lot.stage.release_date.year * 12 + lot.stage.release_date.month)
      (1..total_periods_payments).each do |payments|
        relative_payments = payments + expired_months
        relative_plan = relative_plans.select { |plan| plan.total_payments <= relative_payments }
        relative_discounts << RelativePlan.new(total_payments: payments, discount: relative_plan.first.discount * 100)
      end
    else
      (1..total_periods_payments).each do |payments|
        relative_plan = relative_plans.select { |plan| plan.total_payments <= payments }
        relative_discounts << RelativePlan.new(total_payments: payments, discount: relative_plan.first.discount * 100)
      end
    end

    relative_discounts.group_by(&:discount) || Array.new
  end

  def simple_quotations(relative_plans, lot, lot_area, zero_rate_extra, exclusive_promotion: 0, exclusive_promotion_operation: nil, promotion: nil, coupon: nil, down_payment: 0, price: nil, use_compound_interest: true)
    stage_date = lot.stage.phase.start_date

    coupon_promotion = coupon.present? ? coupon.promotion.amount : 0
    coupon_promotion_operation = coupon.present? ? coupon.promotion.operation : nil
    promotion_amount = promotion.present? ? promotion.amount : 0
    promotion_operation = promotion.present? ? promotion.operation : nil

    periods = validate_credit(lot.stage.credit_scheme.periods.order(order: :ASC))
    periods = periods.each { |period| period.interest = 0 } if lot.stage.credit_scheme.simple_interest?
    end_date = (stage_date + periods.first.payments.months)
    first_period_payments = (end_date.year * 12 + end_date.month) - (stage_date.year * 12 + stage_date.month)

    plans = []

    relative_plans.each do |discount, level|
      level.each do |plan|
        promo = promotion_calculator(price, (plan.discount / 100), exclusive_promotion, exclusive_promotion_operation, promotion_amount, promotion_operation, coupon_promotion, coupon_promotion_operation)
        price_without_down_payment = promo.total - down_payment
        updates = period_calculation(
          payments: plan.total_payments,
          balance: price_without_down_payment,
          first_period_payments: first_period_payments,
          second_period_payments: periods.first.payments + periods.second.payments,
          credit_scheme: periods,
          use_compound_interest: use_compound_interest,
            )

        plans << {
            payments: plan.total_payments,
            price: promo.total,
            discount: promo.discount,
            updates: updates
        }
      end
    end

    plans
  end

  def term_name(terms)
    # todo: verify if i18n can do this
    (terms == 1) ? "Contado" : "#{terms} meses"
  end

  def simple_quotation_select(quote)
    [ "#{term_name(quote[:payments])} - #{number_to_currency(quote[:updates].first[:amount])}", quote[:payments] ]
  end

  def period_calculation(payments:,
                         balance:,
                         first_period_payments: payments,
                         second_period_payments: 0,
                         credit_scheme: [],
                         down_payment: false,
                         use_compound_interest: true
  )

    total_payments = payments > 0 ? payments : 1
    capital_debt = balance

    if down_payment
      updates = down_payment_interest(total_payments: total_payments,
                                       capital_debt: capital_debt,
                                       first_period_payments: first_period_payments
      )
    elsif use_compound_interest
      updates = compound_interest(credit_scheme: credit_scheme,
                                   total_payments: total_payments,
                                   capital_debt: capital_debt,
                                   first_period_payments: first_period_payments,
                                   second_period_payments: second_period_payments,
                                   prev_interest_percentage: 0,
                                   prev_payments_in_period: 0,
                                   update_amount: 0
      )
    else
      updates = simple_interest(credit_scheme: credit_scheme,
                                 total_payments: total_payments,
                                 capital_debt: capital_debt,
                                 update_amount: 0
      )
    end

    updates
  end

  def down_payment_interest(total_payments:, capital_debt:, first_period_payments:)
    update_amount = pmt(0, total_payments, -capital_debt)
    actual_payments = first_period_payments
    actual_payments = total_payments if actual_payments > total_payments
    [ { interest: "Actualización 1", amount: update_amount, payments: actual_payments, rate: 0 } ]
  end

  def compound_interest(credit_scheme:, total_payments:, capital_debt:, first_period_payments:, second_period_payments:, prev_interest_percentage: 0, prev_payments_in_period: 0, update_amount: 0)
    updates = Array.new

    credit_scheme.each_with_index do |period, index|
      if total_payments.to_i > 0
        actual_payments = period.payments

        if period.interest.zero?
          update_amount = pmt(period.interest, total_payments, -capital_debt)
        else
          capital_debt = capital_debt * (1 + prev_interest_percentage)**(prev_payments_in_period) - fv(prev_interest_percentage, prev_payments_in_period, -update_amount)
          update_amount = pmt(period.interest / 100, total_payments, -capital_debt)
        end

        if index == 0
          actual_payments = first_period_payments
        elsif index == 1
          actual_payments = (second_period_payments - first_period_payments)
        end

        if actual_payments > total_payments
          actual_payments = total_payments
        end

        prev_interest_percentage = period.interest / 100
        prev_payments_in_period = actual_payments

        total_payments -= actual_payments
        updates << { interest: "Actualización #{index + 1}", amount: update_amount, payments: actual_payments, rate: period.interest / 100 }
      end
    end
    updates
  end

  def simple_interest(credit_scheme:, total_payments:, capital_debt:, update_amount: 0)
    # TODO: Implement expired months
    periods_in_range = Array.new
    actual_payments = 0
    credit_scheme.each do |period|
      periods_in_range << period if period.payments > 0 && actual_payments + 1 <= total_payments
      actual_payments += period.payments
    end
    periods_in_range << credit_scheme.first if periods_in_range.empty?
    capital_debt = capital_debt * (1 + 0)**(0) - fv(0, 0, -update_amount)
    update_amount = pmt(periods_in_range.last.interest / 100, total_payments, -capital_debt)
    [ { interest: "Actualización 1", amount: update_amount, payments: total_payments, rate: periods_in_range.last.interest / 100 } ]
  end

  def generate_amr(initial_date, updates, debt, capital: [])
    ## Moving code here to be used in generate_amortization
    amr = []
    current_debt = debt
    interest = 0
    number = 0

    updates.each do |update|
      (1..update[:payments]).each do |payment_numb|
        number = number + 1
        interest = current_debt * update[:rate]
        payment = update[:amount]
        current_debt = current_debt - payment
        amr << {
            date: initial_date.next_month(number),
            number: number,
            interest: interest,
            down_payment: 0,
            capital: payment,
            payment: (payment + interest),
            amount: "%.2f" % current_debt
        }
      end
    end

    amr
  end

  private

    def validate_credit(schemes)
      schemes = schemes.to_a
      if schemes.count == 0
        schemes << Period.new(payments: 60, interest: 0)
        schemes << Period.new(payments: 0, interest: 0)
        schemes << Period.new(payments: 0, interest: 0)
      elsif schemes.count == 1
        schemes << Period.new(payments: 0, interest: 0)
        schemes << Period.new(payments: 0, interest: 0)
      elsif schemes.count == 2
        schemes << Period.new(payments: 0, interest: 0)
      end
      schemes
    end

    def mortgage_calculator(rate, periods, amount, final = nil)
      periods = periods
      if periods <= 0
        return 0
      end

      if rate.zero?
        amount / periods
      else
        if final.nil?
          ((amount) * (rate / (1 - (1 + rate)**(-periods))))
        else
          if final.nil?
            ((amount) * (rate / (1 - (1 + rate)**(-periods))))
          else
            ((amount - final * ((1 + rate)**(-periods))) / ((1 - (1 + rate)**(-periods)) / rate))
          end
        end
      end
    end

    def dfp_calculation(payments:, balance:, dfp:, first_period_payments:, second_period_payments: nil)
      period_a = mortgage_calculator(0, payments, balance)

      if payments <= first_period_payments

        [
            { interest: "Actualización 1", amount: period_a, payments: payments, rate: 0.0000 },
            { interest: "Actualización 2", amount: 0, payments: 0, rate: 0.0100 },
            { interest: "Actualización 3", amount: 0, payments: 0, rate: 0.0125 }
        ]
      elsif (payments > first_period_payments) && (payments <= second_period_payments)
        period_b = mortgage_calculator(0.0100, payments - first_period_payments, balance - (period_a * first_period_payments))

        [
            { interest: "Actualización 1", amount: period_a, payments: first_period_payments, rate: 0.0000 },
            { interest: "Actualización 2", amount: period_b, payments: payments - first_period_payments, rate: 0.0100 },
            { interest: "Actualización 3", amount: 0, payments: 0, rate: 0.0125 }
        ]
      else
        final_period_value = (balance * dfp)
        period_b = mortgage_calculator(0.0100, (second_period_payments - first_period_payments), balance - (period_a * first_period_payments), final_period_value)
        period_c = mortgage_calculator(0.0125, payments - (second_period_payments), final_period_value)

        [
            { interest: "Actualización 1", amount: period_a, payments: first_period_payments, rate: 0.0000 },
            { interest: "Actualización 2", amount: period_b, payments: (second_period_payments - first_period_payments), rate: 0.0100 },
            { interest: "Actualización 3", amount: period_c, payments: (payments - second_period_payments), rate: 0.0125 }
        ]
      end
    end

    def select_current_period(payment_number:, first_period_payments:, second_period_payments:, third_period_payments:, periods:, total_payments:, total_periods:, delay_hash:, amr_calc:, fourth_period_calculated:)
      if payment_number <= first_period_payments
        current_period = periods.first
        first_period = first_period_payments - payment_number
        second_period = second_period_payments - first_period_payments + first_period
      elsif (payment_number > first_period_payments) && (payment_number <= second_period_payments)
        current_period = periods.second
        first_period = 0
        second_period = second_period_payments - payment_number
      elsif payment_number > second_period_payments && (payment_number <= third_period_payments)
        current_period = periods.third
        first_period = 0
        second_period = 0
      elsif payment_number > third_period_payments && delay_hash[:delay_last] > 0
        if fourth_period_calculated
          current_period = periods.fourth
        else
          fourth_interest = 1.5 / 100
          payments_in_fourth_period = total_payments + delay_hash[:delay_last] - total_periods
          update_amount = pmt(fourth_interest, payments_in_fourth_period, -amr_calc)
          periods << { interest: "Actualización 4", amount: update_amount.to_f, payments: payments_in_fourth_period, rate: fourth_interest }
          current_period = periods.last
          fourth_period_calculated = true
        end
      else
        current_period = periods.last
      end

      { current_period: current_period, fourth_period_calculated: fourth_period_calculated, first_period: first_period, second_period: second_period }
    end

    def process_capital_payments(capital_payments, buy_price, area, discount, delay_hash, payment_number, amr_calc, total_payments, first_period_payments, first_period, second_period, credit_scheme, second_period_payments, third_period_payments, total_periods, fourth_period_calculated, interest, dfp, periods, payment, quotation_with_capital_payment, actual_day, grace_month, use_compound_interest, amr_calc_extra, total, promo)
      capital_amount = 0

      capital_payments.each do |capital_payment|
        if capital_payment[:installment_number] == payment_number && Restructure::CONCEPT[:DAY] == capital_payment[:concept]
          grace_month += capital_payment[:grace_months] if capital_payment[:grace_months].present?
          actual_day = capital_payment[:current_day]
        end

        if capital_payment[:installment_number] == payment_number && (Restructure.financing_concept?(capital_payment[:concept]) || Restructure.restructure_concept?(capital_payment[:concept]) || Restructure.delay_concept?(capital_payment[:concept]))
          if Restructure.restructure_concept?(capital_payment[:concept]) && discount > capital_payment[:current_discount]
            amr_calc_extra = buy_price * area * (discount - capital_payment[:current_discount])
            amr_calc += amr_calc_extra
            discount = capital_payment[:current_discount]
          end

          if Restructure.restructure_concept?(capital_payment[:concept]) && capital_payment[:without_promotions]
            total_with_promotions = promo.total
            promo = promotion_calculator(total, discount)
            total_without_promotions = promo.total
            amr_calc_extra = total_without_promotions - total_with_promotions
            amr_calc += amr_calc_extra
          end

          if Restructure.delay_concept?(capital_payment[:concept])
            delay_hash[:delay_months] = capital_payment[:delay_months].to_i
            delay_hash[:delay_type] = capital_payment[:concept]
          end

          if capital_payment[:concept] == Restructure::CONCEPT[:FINANCING_MONTHLY] || Restructure.restructure_concept?(capital_payment[:concept])
            if capital_payment[:concept] == Restructure::CONCEPT[:RESTRUCTURE]
              actual_term = capital_payment[:current_term] - payment_number + 1
              debt = amr_calc
            else
              capital_amount += capital_payment[:capital_paid]
              payment = capital_amount if capital_payment[:concept] != Restructure::CONCEPT[:RESTRUCTURE_NEXT]

              if capital_payment[:concept] == Restructure::CONCEPT[:FINANCING_MONTHLY]
                folder_id = capital_payment[:folder_id]
                payments = Payment.without_restructures(folder_id, payment_number)
                down_payment = 0
                down_payment = payments.first.installment.down_payment if payments.first.present?
                if payments.size > 0
                  capital_paid = payments.sum(:amount) - down_payment
                  payment += capital_paid
                end
              end

              actual_term = capital_payment[:current_term] - payment_number
              debt = amr_calc + interest - payment
            end

            if dfp.present?
              periods = dfp_calculation(
                payments: actual_term,
                balance: debt,
                dfp: dfp,
                first_period_payments: first_period,
                second_period_payments: second_period
              )
            else
              periods = period_calculation(
                payments: actual_term,
                balance: debt,
                first_period_payments: first_period,
                second_period_payments: second_period,
                credit_scheme: credit_scheme,
                use_compound_interest: use_compound_interest
              )
            end
          end

          if capital_payment[:concept] == Restructure::CONCEPT[:RESTRUCTURE]
            selected_period = select_current_period(
              payment_number: payment_number,
              first_period_payments: first_period_payments,
              second_period_payments: second_period_payments,
              third_period_payments: third_period_payments,
              periods: periods,
              total_payments: total_payments,
              total_periods: total_periods,
              delay_hash: delay_hash,
              amr_calc: amr_calc,
              fourth_period_calculated: fourth_period_calculated
            )

            current_period = selected_period[:current_period]
            fourth_period_calculated = selected_period[:fourth_period_calculated]
            current_period ||= periods.last
            interest = amr_calc * current_period[:rate]
            payment = current_period[:amount]
          end

          if capital_payment[:concept] == Restructure::CONCEPT[:FINANCING_TIME]
            quotation_with_capital_payment = true
            amr_calc = (amr_calc - capital_payment[:capital_paid])
          end
        end
      end

      {
        periods: periods,
        delay_hash: delay_hash,
        amr_calc: amr_calc,
        payment: payment,
        interest: interest,
        quotation_with_capital_payment: quotation_with_capital_payment,
        grace_month: grace_month,
        actual_day: actual_day,
        amr_calc_extra: amr_calc_extra,
        discount: discount,
        promo: promo
      }
    end

    def process_down_payment_capital_payments(capital_payments, payment_number, payment, credit_scheme, down_payment_calc, quotation_with_capital_payment, down_payment_monthly_payment, first_payment_down_payment)
      capital_amount = 0
      capital_payments.each do |capital_payment|
        if (capital_payment[:installment_number].to_i == payment_number) && Restructure.down_payment_concept?(capital_payment[:concept])
          capital_amount += capital_payment[:capital_paid]

          if capital_payment[:concept] == Restructure::CONCEPT[:DOWN_PAYMENT_MONTHLY]
            payment = capital_amount
            actual_term = capital_payment[:current_term] - payment_number
            debt = down_payment_calc - capital_amount
            down_payment_monthly_payment = period_calculation(
              payments: actual_term,
              balance: debt,
              credit_scheme: credit_scheme,
              down_payment: true
            )
          end

          if capital_payment[:concept] == Restructure::CONCEPT[:DOWN_PAYMENT_TIME]
            quotation_with_capital_payment = true
            down_payment_calc = down_payment_calc - capital_payment[:capital_paid]
          end
        end
      end

      {
        down_payment_calc: down_payment_calc,
        quotation_with_capital_payment: quotation_with_capital_payment,
        down_payment_monthly_payment: down_payment_monthly_payment,
        payment: payment,
        first_payment_down_payment: first_payment_down_payment
      }
    end

    def calculate_buy_price_with_periods(total_payments, buy_price, periods, zero_rate_extra)
      accumulated_payments = 0
      actual_period = Hash.new
      periods.each do |period|
        accumulated_payments += period[:payments]
        if !period[:payments].zero? && accumulated_payments >= total_payments
          actual_period = period
          break
        end
      end
      interest = actual_period[:interest] || 0
      buy_price * (1 + ((total_payments - zero_rate_extra) * interest) / 100)
    end

    def show_interest(credit_scheme)
      !credit_scheme.simple_interest?
    end

    def add_last_payment(date, last_payment_amount)
      {
        date: date,
        number: "CE",
        interest: 0,
        down_payment: 0,
        capital: last_payment_amount,
        capital_payment: 0,
        concept: Installment::CONCEPT[:LAST_PAYMENT],
        payment: last_payment_amount,
        amount: 0
      }
    end

    def promotion_select_label(promotions)
      promotions.map { |p| [p.show_percentage ? "#{p.name} (#{'%.2f' % (p.amount * 100)}%)" : p.name, p.id] }
    end
end
