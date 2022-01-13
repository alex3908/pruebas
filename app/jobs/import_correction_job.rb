# frozen_string_literal: true

require "caxlsx"

class ImportCorrectionJob < ApplicationJob
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
            if folder.status != Folder::STATUS[:CANCELED] || folder.status != Folder::STATUS[:EXPIRED]
              payment_scheme = folder.payment_scheme
              payment_scheme.update!(down_payment: row["down_payment_balance"]) if row["down_payment_balance"].present?
              payment_scheme.update!(initial_payment: row["section"]) if row["section"].present?
              payment_scheme.update!(total_payments: row["financing_term"]) if row["financing_term"].present?
              payment_scheme.update!(down_payment_finance: row["down_payment_term"]) if row["down_payment_term"].present?
              payment_scheme.update!(buy_price: row["square_meter_price"]) if row["square_meter_price"].present?
              payment_scheme.update!(discount: row["discount"]) if row["discount"].present?
              if row["deferred"].present? && row["deferred"] == "Si"
                payment_scheme.update!(start_installments: row["grace_period_discount"]) if row["grace_period_discount"].present?
              else
                payment_scheme.update!(start_installments: nil)
              end
              payment_scheme.update!(zero_rate: row["interest_free_months"]) if row["interest_free_months"].present?
            end
          end

          job_status.add_progress!("Guardando fila: #{idx}...")

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
        section: "Apartado",
        down_payment_balance: "Saldo de enganche",
        down_payment_term: "Plazo del enganche",
        financing_term: "Plazo del financiamiento",
        interest_free_months: "Meses sin intereses",
        square_meter_price: "Precio por m2",
        discount: "Descuento",
        grace_period_discount: "Meses de gracia",
        deferred: "Diferido"
      }
    end


    def excel_header
      [
        "Lote",
        "Apartado",
        "Saldo de enganche",
        "Plazo del enganche",
        "Plazo del financiamiento",
        "Meses sin intereses",
        "Precio por m2",
        "Descuento",
        "Meses de gracia",
        "Diferido"
      ]
    end
end
