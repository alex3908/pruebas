# frozen_string_literal: true

module InstallmentConcern
  extend ActiveSupport::Concern

  def invoice(cash_flow_id, payment_id, receipt = true, with_signature = true)
    @branches = Branch.where(active: true)
    @with_signature = with_signature
    @name = receipt ? "RECIBO DE " : "COMPROBANTE DE "

    if cash_flow_id.present?
      @cash_flow = CashFlow.find(cash_flow_id)
      @user = @cash_flow.user
      @name += "PAGO"
    else
      @payment = Payment.find(payment_id)
      @user = @payment.user
      @name += "REESTRUCTURA"
    end

    render_to_string("installments/new_format/invoice.html.erb", layout: "layouts/pdf.html.erb")
  end

  def reload_installments(folder)
    quotation = folder.generate_quote
    all_installments = quotation.down_payment_monthly_payments | quotation.amr
    updated_installments = []

    all_installments.each_with_index do |installment, index|
      concept = installment[:concept]
      installment_to_update = Installment.find_by(folder: folder, number: installment[:number], concept: concept, is_custom: false)

      installment_attributes = {
        number: installment[:number],
        date: installment[:date].to_date,
        down_payment: installment[:down_payment].round(2),
        total: installment[:payment].round(2),
        capital: installment[:capital].present? ? installment[:capital].round(2) : nil,
        interest: installment[:interest].present? ? installment[:interest].round(2) : nil,
        debt: installment[:amount].present? ? installment[:amount] : nil,
        folder: folder,
        concept: concept,
        deleted_at: nil,
      }

      if installment_to_update.nil?
        installment_to_update = Installment.create(installment_attributes)
      else
        installment_to_update.update_attributes!(installment_attributes)
      end

      updated_installments << installment_to_update.id
    end

    folder.installments.where.not(id: updated_installments).update_all(deleted_at: Time.zone.now)
    folder.update(total_sale: quotation.total_with_discount)
  end
end
