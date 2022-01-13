# frozen_string_literal: true

require "caxlsx"

class ImportPaymentsJob < ApplicationJob
  include ExportExcelErrors
  queue_as :low_priority

  @job_status = nil

  def perform(job_status, stage_id)
    @job_status = job_status

    job_status.add_progress!("Importando correcciones...")
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
        sheet.each_with_index(headers) do |row, idx|
          lot = Lot.find_by(stage: stage_id, name: row["lot"])
          folder = Folder.find_by(lot_id: lot.id, step: Step.last_step)

          if folder.present?
            installment = Installment.find_by(folder: folder, number: row["payment_number"], concept: row["payment_concept"])
            if installment.nil?
              installment = Installment.new
              installment.folder = folder
              installment.number = row["payment_number"]
              installment.concept = row["payment_concept"]
              installment.save!
            end

            payment_method = PaymentMethod.find_by("LOWER(name) LIKE LOWER(?)", "%#{row["payment_method"]}%")
            user = User.find_by("LOWER(email) LIKE LOWER(?)", "%#{row["staff"]}%")
            branch = Branch.find_by(name: row["Sucursal"])

            payment = Payment.new
            payment.installment = installment
            payment.date = row["date_of_payment"]
            payment.amount = row["quantity"]
            payment.payment_method = payment_method
            payment.user = user
            payment.client = folder.client
            payment.branch_id = branch.nil? ? folder.user.branch_id : branch.id
            payment.bank_account = BankAccount.find_by(clabe: row["payment_specification"].tr(" ", ""))
            payment.save!
          end
        rescue ActiveRecord::RecordInvalid => ex
          job_status.add_progress!("Error fila #{idx}: #{ex.message}")
          excel_rows << build_excel_row(row, ex.message)
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
    (job_status = attach_excel_file(excel_rows, job_status)) if excel_rows.size > 0

    if columns_with_error.empty?
      job_status.mark_completed!
    end

  rescue StandardError => e
    job_status.mark_failed!(e.to_s)
    job_status.log_error!(e)
    Bugsnag.notify(e)
  end

  private

    def headers
      {
        lot: "Lote",
        folio: "Folio",
        date_of_payment: "Fecha de pago",
        payment_number: "Número de pago",
        payment_concept: "Concepto de pago",
        payment_method: "Forma de pago",
        payment_specification: "Especificación de pago",
        staff: "Personal",
        quantity: "Cantidad"
      }
    end


    def excel_header
      [
        "Lote",
        "Folio",
        "Fecha de pago",
        "Número de pago",
        "Concepto de pago",
        "Forma de pago",
        "Especificación de pago",
        "Personal",
        "Cantidad"
      ]
    end
end
