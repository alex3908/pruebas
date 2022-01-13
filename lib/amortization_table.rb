# frozen_string_literal: true

class AmortizationTable < DocumentHandler
  FILE_PATH = "folders/files/new_format/amortization_table.html.erb"
  attr_reader :folder, :project, :show_table, :quotation, :with_signature, :is_digital_signature, :amr, :down_payment_installments, :capital_total, :interest_total, :payment_total, :down_payment_total, :capital_payments_total, :smaller_amortization

  def initialize(folder, project, with_signature, is_digital_signature)
    @folder ||= folder
    @quotation ||= quotation
    @project ||= project
    @show_table = true
    @with_signature = with_signature
    @is_digital_signature = is_digital_signature
    super(FILE_PATH, layout: "pdf.html")
  end

    protected

      def assigns
        table_data = table_data(folder)
        {
          folder: folder,
          project: project,
          lot: folder.lot,
          stage: folder.stage,
          phase: folder.phase,
          show_table: show_table,
          quotation: table_data[:quotation],
          with_signature: with_signature,
          is_digital_signature: is_digital_signature,
          amr: table_data[:amr],
          down_payment_installments: table_data[:down_payment_installments],
          capital_total: table_data[:capital_total],
          interest_total: table_data[:interest_total],
          payment_total: table_data[:payment_total],
          down_payment_total: table_data[:down_payment_total],
          capital_payments_total: table_data[:capital_payments_total],
          smaller_amortization: table_data[:smaller_amortization]
        }
      end

      def locals
        {}
      end

      def table_data(folder)
        quotation = folder.generate_quote
        amr = Installment.where(folder: folder, deleted_at: nil, concept: Installment::CONCEPT[:FINANCING])

        smaller_amortization = Setting.find_by_key("smaller_amortization_table").try(:convert)

        amr = amr.sort_by { |payment| payment.number.to_i }
        last_payment_installment = Installment.where(folder: folder, deleted_at: nil, concept: Installment::CONCEPT[:LAST_PAYMENT])
        amr = amr + last_payment_installment
        if smaller_amortization
          amr = amr.each_slice(40).to_a.each_slice(2).to_a
        else
          amr = amr.each_slice(20).to_a
        end

        installments = Installment.where(folder: folder, deleted_at: nil)
        down_payment_installments = installments.where.not(concept: [Installment::CONCEPT[:FINANCING], Installment::CONCEPT[:LAST_PAYMENT]])
        down_payment_installments = down_payment_installments.sort_by { |payment| payment.number.to_i }

        capital_total = quotation.amr.inject(0) { |sum, payment| sum + payment[:capital] }
        interest_total = quotation.amr.inject(0) { |sum, payment| sum + payment[:interest] }
        payment_total = quotation.amr.inject(0) { |sum, payment| sum + payment[:payment] }
        payment_total += quotation.down_payment_monthly_payments.inject(0) { |sum, payment| sum + payment[:payment] }

        if quotation.is_down_payment_differ
          down_payment_total = quotation.amr.inject(0) { |sum, payment| sum + payment[:down_payment] }
          down_payment_total += quotation.down_payment_monthly_payments.inject(0) { |sum, payment| sum + payment[:payment] }
        else
          down_payment_total = quotation.down_payment_monthly_payments.inject(0) { |sum, payment| sum + payment[:payment] }
        end

        capital_payments_total = quotation.amr.inject(0) { |sum, payment| sum + payment[:capital_payment] } if quotation.have_capital_payment

        {
         quotation: quotation,
         amr: amr,
         down_payment_installments: down_payment_installments,
         capital_total: capital_total,
         interest_total: interest_total,
         payment_total: payment_total,
         down_payment_total: down_payment_total,
         capital_payments_total: capital_payments_total,
         smaller_amortization: smaller_amortization
        }
      end
end
