# frozen_string_literal: true

class CashFlowImportJob < ApplicationJob
  include PaymentProcessorConcern, ExportExcelErrors, FolderPayActionsConcern
  queue_as :low_priority

  def perform(job_status)
    job_status.add_progress!("Importando Flujos de Caja ...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode
    excel_rows = []
    columns_with_error = []

    job_status.add_progress!("Leyendo hoja de cálculo...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      sheet = book.sheet(0)

      begin
        sheet.each_with_index(header) do |row, index|
          ActiveRecord::Base.transaction do
            next if index == 0
            @locals = {}

            job_status.add_progress!("Buscando información para el flujo de caja con índice: #{index + 1}...")

            folder = Folder.find_by!(id: row[:folio])
            client = Client.find_by!(email: row[:client_email].try(:strip).try(:downcase))
            user = User.find_by!(email: row[:user_email])
            payment_method = PaymentMethod.find_by!(name: row[:payment_method].try(:strip))

            # TODO: scope only for the accounts in the project
            if row[:account_number].present?
              bank_account = BankAccount.find_by(account_number: row[:account_number])
            elsif row[:clabe].present?
              bank_account = BankAccount.find_by(clabe: row[:clabe])
            end

            branch = Branch.find_by(name: row[:branch].try(:strip))
            branch = user.branch if branch.nil?
            amount = row[:amount]

            job_status.add_progress!("Generando el flujo de caja con índice: #{index + 1}...")

            cash_flow = create_cash_flow(
              folder: folder,
              client: client,
              payment_method: payment_method,
              bank_account: bank_account,
              branch: branch,
              amount: amount,
              date: row[:date].to_date,
              current_user: user,
            )

            all_installments = set_residue(folder)

            until amount <= 0 do
              raw_installment = all_installments.find { |element| element[:residue] > 0 }
              raw_installment_index = all_installments.index(raw_installment)
              is_down_payment = raw_installment[:concept] == Installment::CONCEPT[:DOWN_PAYMENT]
              installment = create_installment(folder: folder, raw_installment: raw_installment)

              paid = raw_installment[:residue].to_f >= amount ? amount : raw_installment[:residue].to_f
              amount = amount - paid
              payment = create_payment(amount: paid, installment: installment, client: client, branch: branch, cash_flow: cash_flow, current_user: job_status.user)
              create_commissions(installment.down_payment, payment) if payment.persisted? && folder.stage.active_commissions

              if !is_down_payment && folder.payment_scheme.credit_scheme.surplus_amount_to_capital_time
                folder.create_restructure(Restructure::CONCEPT[:FINANCING_TIME], is_down_payment, raw_installment[:concept], amount, raw_installment[:number], branch, cash_flow)
                break
              end

              all_installments[raw_installment_index][:residue] = raw_installment[:residue].to_f - paid
            end
          rescue StandardError => ex
            job_status.add_progress!("Error fila #{index}: #{ex.message}")
            excel_rows << build_excel_row(row, ex.message)
          end
        end
      rescue Roo::HeaderRowNotFoundError => ex
        columns_with_error = JSON.parse(ex.message)
        error_message = "Las siguientes columnas no fueron encontradas en el archivo: #{columns_with_error.join(", ")}."
        job_status.add_progress!(error_message)
        job_status.mark_failed!(error_message)
        job_status.log_error!(ex)
      end

      job_status.add_progress!("Limpiando proceso...")

    ensure
      file.close
      file.unlink
    end

    job_status.file.purge if job_status.file.present?
    (job_status = attach_excel_file(excel_rows, job_status, "Flujos de caja")) if excel_rows.size > 0

    if columns_with_error.empty?
      job_status.mark_completed!
    end
  rescue StandardError => e
    job_status.mark_failed!(e.to_json)
    job_status.log_error!(e)
    Bugsnag.notify(e)
    raise e
  end

  private

    def header
      {
        folio: "Folio",
        client_email: "Correo del Cliente",
        user_email: "Correo del Usuario",
        branch: "Sucursal",
        payment_method: "Método de Pago",
        account_number: "Número de Cuenta Bancaria",
        clabe: "CLABE Interbancaria",
        date: "Fecha de Pago",
        amount: "Monto"
      }
    end

    def excel_header
      [
        "Folio",
        "Correo del Cliente",
        "Correo del Usuario",
        "Sucursal",
        "Método de Pago",
        "Número de Cuenta Bancaria",
        "CLABE Interbancaria",
        "Fecha de Pago",
        "Monto",
        "Observaciones"
      ]
    end
end
