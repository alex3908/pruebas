# frozen_string_literal: true

module PaymentProcessorConcern
  extend ActiveSupport::Concern

  def create_cash_flow(folder:, client:, payment_method: nil, bank_account: nil, branch: nil, amount:, date: Time.zone.now, cash_back: 0, current_user: nil, charge_id: nil)
    cash_flow = CashFlow.create!(
      folder: folder,
      client: client,
      payment_method: payment_method,
      bank_account: bank_account,
      branch: branch,
      user: current_user,
      date: date.strftime("%Y-%m-%d"),
      amount: amount,
      cash_back: cash_back,
      charge_id: charge_id
    )

    unless cash_back.zero?
      cash_backs_available = client.cash_backs.where(exclusive_folder_id: folder.id) + client.cash_backs.where(exclusive_folder_id: nil)
      cash_backs_available = cash_backs_available.filter { |cashback| cashback.last_balance != 0 }

      total = amount
      cash_backs_available.each do |cashback_to_use|
        break if total <= 0
        residue = cashback_to_use.last_balance - total
        total = total - cashback_to_use.last_balance
        balance_left = (residue <= 0 ? 0 : residue.abs).round(2)


        cash_flow.cash_back_flows.create!(
          amount_used: (cashback_to_use.amount - balance_left).round(2),
          balance_after: balance_left,
          cash_back_id: cashback_to_use.id
        )
      end
    end

    cash_flow
  rescue Exception => error
    @locals[:error] = "cash_flow" if @locals.present?
    Bugsnag.notify(error)
  end

  def create_installment(folder:, raw_installment:)
    Installment.where(folder: folder, number: raw_installment[:number], concept: raw_installment[:concept]).first_or_initialize.tap do |installment|
      installment.date = raw_installment[:date]
      installment.down_payment = raw_installment[:down_payment].round(2)
      installment.total = raw_installment[:payment].round(2)
      installment.capital = raw_installment[:capital].present? ? raw_installment[:capital].round(2) : nil
      installment.interest = raw_installment[:interest].present? ? raw_installment[:interest].round(2) : nil
      installment.debt = raw_installment[:amount].present? ? raw_installment[:amount] : nil
      installment.save!
    end
  rescue Exception => error
    @locals[:error] = "installment" if @locals.present?
    Bugsnag.notify(error)
  end

  def create_payment(amount:, installment:, client:, branch: nil, cash_flow: nil, current_user: nil)
    Payment.create!(
      amount: amount.round(2),
      installment: installment,
      client: client,
      branch: branch,
      user: current_user,
      cash_flow: cash_flow
    )
  rescue Exception => error

    @locals[:error] = "payment" if @locals.present?
    Bugsnag.notify(error)
  end

  def create_restructure(payment:, concept:, term:, day:, discount:, grace_months:, delay_months:, without_promotions:)
    Restructure.create!(
      payment: payment,
      concept: concept,
      current_term: term,
      current_day: day,
      current_discount: discount,
      grace_months: grace_months,
      delay_months: delay_months,
      without_promotions: Restructure.restructure_concept?(concept)
    )
  rescue Exception => error
    @locals[:error] = "restructure" if @locals.present?
    Bugsnag.notify(error)
  end

  def create_commissions(down_payment, payment)
    installment = payment.installment
    return unless installment.is_paid?
    folder = installment.folder
    down_payment_total = folder.payment_scheme.initial_payment + folder.payment_scheme.down_payment

    if down_payment_total / folder.total_sale < 0.1
      return
      return unless payment.installment.commissions.not_canceled.empty?

      if payment.installment.concept == Installment.concepts[:initial_payment]
        new_commission(payment, payment.installment.total, irregular: true)
      else
        folder = payment.installment.folder
        max_commission_amount = folder.payment_scheme.max_commission_amount

        zero_total_installments = folder.zero_total_installments.where.not(concept: Installment.concepts[:initial_payment])
        paid_installments = folder.paid_financing_installments + folder.paid_down_payments_installments
        paid_installments_count = paid_installments.length - zero_total_installments.length
        new_commission(payment, max_commission_amount, irregular: true) if paid_installments_count <= (max_commission_amount.nil? ? 0 : max_commission_amount)
      end
    else
      return unless down_payment > 0

      payment_percentage = down_payment / down_payment_total
      new_commission(payment, payment_percentage)
    end
  rescue Exception => error
    @locals[:error] = "commission" if @locals.present?
    Bugsnag.notify(error)
    raise error
  end

  def new_commission(payment, payment_percentage, opts = {})
    payment.installment.folder.folder_users.each do |folder_user|
      folder = folder_user.folder

      if opts[:irregular]
        total_sale = (folder_user.amount * 100 / folder_user.percentage).to_f
        total_sale_sixth_percent = (0.06 * total_sale)
        amount = folder_user.amount * (folder.payment_scheme.initial_payment / total_sale_sixth_percent)

        if payment.installment.concept != Installment.concepts[:initial_payment]
          amount = (folder_user.amount - amount) / payment_percentage
        end
      else
        amount = folder_user.amount * payment_percentage
      end

      paid_commission = Commission.where(
        installment: payment.installment,
        folder_user: folder_user,
        status: Commission::STATUS[:PAID]
      ).take

      if amount > 0 && paid_commission.blank?
        commission = Commission.new
        commission.installment = payment.installment
        commission.payment = payment
        commission.folder_user = folder_user
        commission.amount = amount.round(2)
        commission.date = payment.cash_flow.date
        commission.status = Commission::STATUS[:PENDING]
        commission.save!
      end
    end
  end

  def set_residue(folder)
    quotation = folder.generate_quote
    installments = folder.installments.includes(payments: :restructure)
    all_installments = quotation.down_payment_monthly_payments | quotation.amr
    all_installments.each_with_index do |installment, index|
      is_down_payment = index + 1 <= quotation.down_payment_monthly_payments.length
      all_installments[index][:is_down_payment] = is_down_payment
      all_installments[index][:position] = all_installments.index(installment)
      all_installments[index][:residue] = 0
      concept = index == 0 ? Installment::CONCEPT[:INITIAL_PAYMENT] : is_down_payment ? Installment::CONCEPT[:DOWN_PAYMENT] : Installment::CONCEPT[:FINANCING]
      actual = installments.select { |element| (element.number == installment[:number].to_s && element.concept == concept) }.first
      total_amount = installment[:payment].round(2)
      all_installments[index][:concept] = concept
      if actual.present?
        total_amount += actual.penalty.amount if actual.penalty.present? && actual.penalty.active
        all_installments[index][:residue] = total_amount - actual.total_paid if actual.total_paid < total_amount
      else
        all_installments[index][:residue] = total_amount
      end
    end
    all_installments
  end

  def create_concept_payment(cash_flow: nil, additional_concept: nil)
    AdditionalConceptPayment.create!(
      amount_type: additional_concept.amount_type,
      cash_flow: cash_flow,
      additional_concept: additional_concept
    )
  rescue Exception => error
    @locals[:error] = "additional_concept_payment" if @locals.present?
    Bugsnag.notify(error)
  end

  def create_additional_concept_payment(concept_id, opts = {})
    additional_concept = AdditionalConcept.find(concept_id)
    online_payment_ticket = opts.fetch(:online_payment_ticket, @online_payment_ticket)

    cash_flow = create_cash_flow(
      folder: online_payment_ticket.folder,
      client: online_payment_ticket.client,
      payment_method: online_payment_ticket.online_payment_service.payment_method,
      bank_account: online_payment_ticket.online_payment_service.bank_account,
      amount: online_payment_ticket.amount,
      date: online_payment_ticket.created_at,
    )

    create_concept_payment(cash_flow: cash_flow, additional_concept: additional_concept)
  end
end
