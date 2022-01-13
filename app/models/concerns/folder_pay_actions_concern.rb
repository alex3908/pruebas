# frozen_string_literal: true

module FolderPayActionsConcern
  extend ActiveSupport::Concern
  include PaymentProcessorConcern

  def pay_installments(amount, branch, cash_flow)
    @quotation = self.generate_quote
    locals = {}

    processed_installments.each_with_index do |installment, index|
      residue = 0
      penalty = installment.penalty
      total_amount = installment.total

      total_amount += installment.total + penalty.amount if penalty.present? && penalty.active

      residue = total_amount - installment.total_paid if installment.total_paid < total_amount

      next unless residue > 0

      paid = residue >= amount ? amount : residue
      amount = amount - paid
      @payment = Payment.new(amount: paid.round(2), installment: installment, client: self.client, branch: branch, user: Current.user, cash_flow: cash_flow)

      unless @payment.save
        locals[:error] = "payment"
      end

      create_commissions(installment.down_payment, @payment) if @payment.persisted? && self.stage.active_commissions && self.payment_scheme.is_commissionable
      break if amount <= 0
    end
    { locals: locals, payment: @payment }
  end

  def create_restructure(restructure_type, is_down_payment, concept, amount, number, branch, cash_flow, down_payment_count = nil, payments_count = nil, new_day = nil, current_discount = nil, grace_months = nil, delay_months = nil)
    locals = {}
    installment = Installment.find_by(number: number, folder_id: self.id, concept: concept)
    restructure_type = Restructure::CONCEPT[:FINANCING_TIME] if is_down_payment == "false" && self.payment_scheme.credit_scheme.surplus_amount_to_capital_time
    @payment = Payment.new(amount: amount.round(2), installment: installment, client: self.client, branch: branch, user: Current.user, cash_flow: cash_flow)
    @payment.add_restructure(restructure_type, down_payment_count, payments_count, new_day, current_discount, grace_months, delay_months)

    unless @payment.save
      locals[:error] = "payment"
    end

    { locals: locals, payment: @payment }
  end

  def processed_installments
    installments = self.installments
    initial_payment_installments = installments.where(concept: Installment::CONCEPT[:INITIAL_PAYMENT]).order(number: :desc)
    down_payment_installments = installments.where(concept: Installment::CONCEPT[:DOWN_PAYMENT]).order("number::integer ASC")
    financing_installments = installments.where(concept: Installment::CONCEPT[:FINANCING]).order("number::integer ASC")
    last_payment_installments = installments.where(concept: Installment::CONCEPT[:LAST_PAYMENT]).order(number: :asc)

    initial_payment_installments + down_payment_installments + financing_installments + last_payment_installments
  end


  def generate_cash_flow(restructure_type, payment_method, bank_account, branch, amount, date, client)
    cash_flow_data = { cash_flow: nil }
    if Restructure.amount_concept?(restructure_type)
      cash_flow = create_cash_flow(
        folder: self,
          client: client,
          payment_method: payment_method,
          bank_account: bank_account,
          branch: branch,
          amount: amount,
          date: date,
          cash_back: self.client.cash_back_available(self.id, payment_method: payment_method),
          current_user: Current.user
      )
      cash_flow_data = { cash_flow: cash_flow }
    end
    cash_flow_data
  end
end
