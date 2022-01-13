# frozen_string_literal: true

module InstallmentsHelper
  private

    def tooltip_message(has_restructure, has_overdue = false, is_down_payment = false, is_initial_payment = false, has_financing_restriction_overdue = false)
      return "La mensualidad actual tiene saldo vencido" if has_overdue
      return "La mensualidad actual tiene una reestructura activa" if has_restructure
      return "Esta acción estará disponible cuando se comiencen a pagar las mensualidades" if is_down_payment
      return "Esta acción estará disponible cuando se comiencen a pagar las letras de enganche" if is_initial_payment
      return "No se pueden realizar abonos a capital si el expediente tiene saldos vencidos" if has_financing_restriction_overdue
    end

    def additional_concept_options(folder, stage)
      stage.additional_concepts.map do |concept|
        {
          id: concept.id,
          name: concept.name,
          type: concept.amount_type,
          amount: concept.amount
        }
      end
    end

    def warning_response_message(code, cash_back_available)
      warnings = {
        "not_allowed" => "Se supero el monto permitido del pago usando la bonificación.",
        "not_enough" => "La cantidad disponible como bonificación es de #{ActionController::Base.helpers.number_to_currency(cash_back_available.to_f)}."
      }
      warnings[code]
    end

    def error_response_message(code)
      errors = {
        "cash_flow" => "Hubo un problema al guardar el flujo de caja.",
        "installment" => "Hubo un problema al guardar la mensualidad.",
        "payment" => "Hubo un problema al generar los pagos.",
        "restructure" => "Hubo un problema al generar la reestructura.",
        "commission" => "Hubo un problema al generar la comisión.",
        "additional_concept_payment" => "Hubo un problema al generar el pago del concepto adicional."
      }
      errors[code]
    end

    def generate
      discount = @is_default_quote ? 0 : @folder.payment_scheme.discount
      @installments = @folder.installments.includes(:penalty, payments: :restructure)

      @can_restructure_type = params[:restructure_type] == Restructure::CONCEPT[:FINANCING_MONTHLY]
      @current_discount = @folder.payment_scheme.discount
      if @is_default_quote
        total_payments = @folder.payment_scheme.credit_scheme.periods.inject(0) { |sum, period| sum + period.payments }
      else
        total_payments = @folder.payment_scheme.total_payments
      end

      if @folder.has_custom_installments?
        total_payments = @folder.financing_installments.size
      end

      if Restructure::CONCEPT[:RESTRUCTURE] == params[:restructure_type]
        quotation = @folder.generate_quote
        @min_total_payments = quotation.payments
      end

      restructures = @folder.get_restructures
      if params[:restructure_type].present? && (params[:adjust].present? || params[:new_date].present? || params[:delay_months])
        restructures << restructure_installment(params[:adjust].to_i, @folder, @lot, params[:restructure_type], params[:down_payment_count].to_i, params[:next_down_payment].to_i, params[:next].to_i, params[:next_date], params[:new_date], params[:delay_months], params[:amount], Restructure.restructure_concept?(params[:restructure_type]))
      end

      quotation = @folder.generate_quote(total_payments, discount, restructures)

      @is_default_quote ? @default_quotation = quotation : @quotation = quotation
    end

    def set_configuration
      @amount_overdue = 0
      @capital_amount_overdue = 0
      @total_residue = 0
      @capital_next_overdue = 0
      @paid_capital_amount = 0
      @has_restructure = false
      @has_financing_restriction_overdue = false
      @payment_methods = PaymentMethod.visible
      @branches = Branch.all
      @payments = Payment.active.where(installment: @installments).order(:id)
      @all_installments = @quotation.down_payment_monthly_payments | @quotation.amr
      @payment_total = @all_installments.inject(0) { |sum, payment| sum + payment[:payment] }
      @total_payments = @quotation.payments
      @down_payment_count = @all_installments.select { |installment| installment[:down_payment] > 0 && installment[:number] != "A" }.size
      @payments_count = @quotation.payments
      @quotation_total_payments = @folder.quotation_total_payments
    end

    def validate_errors
      only_finance_installments = @installments.where(concept: Installment::CONCEPT[:FINANCING], deleted_at: nil).count
      @minimum_term = only_finance_installments > 0 ? only_finance_installments : 1
      @maximum_term = @base_total_payments
      @adjust_months_error = true if params[:adjust].present? && [Restructure::CONCEPT[:FINANCING_MONTHLY], Restructure::CONCEPT[:RESTRUCTURE]].include?(params[:restructure_type]) && ((params[:adjust].to_i < @minimum_term) || (params[:adjust].to_i > @maximum_term))
      @capital_amount_error = true if params[:amount].present? && params[:amount].to_i < @stage.credit_scheme.min_capital_payment
    end

    def set_default_quote
      @is_default_quote = true
      generate
      @payment_total_default = @default_quotation.total_with_discount
    end

    def set_additional_concept_payments
      payments = AdditionalConceptPayment.joins(:cash_flow, :additional_concept).includes(:cash_flow, :additional_concept).where(cash_flows: { folder: @folder, status: :active }).order(created_at: :asc)
      @additional_concepts_payments = payments.map { |payment|
        additional_concept = payment.additional_concept
        cash_flow = payment.cash_flow
        {
          additional_concept_id: additional_concept.id,
          name: additional_concept.name,
          status: "PAGADO",
          status_class: "primary-row",
          date: only_date(cash_flow.created_at),
          amount: additional_concept.amount,
          payment_amount: cash_flow.amount,
          amount_type: additional_concept.amount_type,
          amount_type_label: amount_type_label(additional_concept.amount_type)
        }
      }

      @stage.additional_concepts.active.each do |additional_concept|
        next if @additional_concepts_payments.any? { |payment| payment[:additional_concept_id] == additional_concept.id }
        @additional_concepts_payments << {
          additional_concept_id: additional_concept.id,
          name: additional_concept.name,
          status: "PENDIENTE",
          status_class: "normal-row",
          date: "-",
          amount: additional_concept.amount,
          payment_amount: 0,
          amount_type: additional_concept.amount_type,
          amount_type_label: amount_type_label(additional_concept.amount_type)
        }
      end
    end

    def transform_new_payment_data
      now = Time.zone.now
      @total_residue = 0
      @next_installment = nil
      next_counter = 0
      @persisted_installments = []
      @folder.processed_installments.each do |installment|
        penalty_amount = 0

        total_paid = installment.total_paid
        penalty = installment.penalty
        has_penalty = penalty.present? && penalty_amount.present? && penalty.active
        penalty_amount = penalty&.amount if has_penalty
        total_amount = installment.total + penalty_amount
        is_paid =  total_paid >= total_amount
        residue = is_paid ? 0 : total_amount - total_paid
        overdue = installment.date < now && residue > 0
        next_overdue = installment.date >= now && installment.date < now.next_day(@stage.payment_expiration) && residue > 0
        @total_residue += residue

        processed_installment = {
          paid: is_paid,
          overdue: overdue,
          next_overdue: next_overdue,
          is_multiple: false,
          number: installment.number,
          date: installment.date.strftime("%d/%m/%Y"),
          capital: installment.capital,
          interest: installment.interest,
          down_payment: installment.down_payment,
          payment: installment.total,
          has_penalty: has_penalty,
          residue: residue,
          penalty: penalty_amount,
          amount: installment.debt,
          can_add_penalty: false,
          can_show_new_folder_installment: can?(:create, Penalty) && !has_penalty,
          can_show_folder_installment_penalties: can?(:update, Penalty) && has_penalty,
          is_down_payment: installment.concept == Installment::CONCEPT[:DOWN_PAYMENT],
          row_color: installment_table_class(paid: is_paid, overdue: overdue, next_overdue: next_overdue, is_multiple: false),
          status_message: installment_table_message(paid: is_paid, overdue: overdue, next_overdue: next_overdue, is_multiple: false),
          add_penalty_url: new_folder_installments_penalties_path(@folder, installment),
          remove_penalty_url: folder_installments_penalties_path(@folder, installment),
          installment_capital_payment: installment.capital_payment.round(2),
          total_paid: total_paid,
          total_amount: total_amount,
          restructure_concepts: installment.restructure_concepts,
          overdue_days: installment_overdue_days(overdue, now.to_date, installment.date)
        }

        @next_installment = processed_installment if !is_paid && @next_installment.nil?

        if !@next_installment.nil? && @payment_method.present? && @payment_method.cash_back && next_counter.zero?
          set_bonus_residue(@next_installment, installment, total_paid, residue)
          next_counter += 1
        end
        processed_installment[:can_add_penalty] = processed_installment[:residue] <= 0 || processed_installment == @next_installment

        @persisted_installments << processed_installment
      end
    end

    def slice_payments
      @cash_flows = CashFlow.active.where(folder: @folder).includes(:client, :branch, :payment_method, payments: [:installment, :restructure]).order(:id)
      @slice_cash_flows = @cash_flows.each_slice(20).to_a
      account_status_data(@persisted_installments)
      @slice_installments = @persisted_installments.each_slice(20).to_a
    end

    def account_status_data(installments)
      installments.each do |installment|
        pending_payment = 0
        restructure_label = ""
        restructures = installment[:restructure_concepts]
        restructures.each do |restructure|
          restructure_label += "#{restructure.concept_label} <br>"
        end
        installment[:type_capital_payment] = restructure_label if !restructure_label.blank?

        @paid_capital_amount += installment[:installment_capital_payment]
        capital_payment = pending_capital = installment[:down_payment] + (installment[:capital] || 0)
        if installment[:paid]
          @paid_capital_amount += capital_payment.round(2)
        else
          pending_payment = installment[:total_amount] - installment[:total_paid]
          pending_capital = installment[:total_paid] - (installment[:interest].nil? ? 0 : installment[:interest]) >= 0 ? pending_payment : capital_payment
          @paid_capital_amount += (capital_payment - pending_capital).round(2)
        end

        @total_residue += pending_payment

        if installment[:overdue]
          @capital_amount_overdue += pending_capital
          @amount_overdue += pending_payment
        end

        if installment[:next_overdue]
          @capital_next_overdue += capital_payment
        end
      end

      @has_overdue = @amount_overdue > 0
      pending_capital_amount_total = @folder.total_sale - @paid_capital_amount
      @pending_capital_amount = pending_capital_amount_total <= 0 ? 0 : pending_capital_amount_total
      @has_financing_restriction_overdue = true if @capital_amount_overdue > 0
    end
end
