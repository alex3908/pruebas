# frozen_string_literal: true

require "caxlsx"

class ImportInstallmentsJob < ApplicationJob
  include ExportExcelErrors
  queue_as :low_priority

  @total_sale = 0

  def perform(job_status)
    job_status.add_progress!("Importando tabla de amortización...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode
    excel_rows = []
    columns_with_error = []
    installment_numbers = []
    folder = nil

    job_status.add_progress!("Leyendo hoja de cálculo...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      sheet = book.sheet(0)

      begin
        sheet.each_with_index(headers) do |row, idx|
          next if row[:capital] == "Capital" || row[:capital].nil?

          if folder&.id != row[:folder_id].to_i
            folder = Folder.find_by(id: row[:folder_id].to_i)
            @total_sale = folder.total_sale
          end

          installment = build_installment(row, job_status, idx)
          installment_numbers << { id: installment.id, concept: installment.concept }
        rescue ActiveRecord::RecordInvalid => ex

          job_status.add_progress!("Error fila #{idx}: #{ex.message}")
          excel_rows << build_excel_row(row, ex.message)
        end

        installments = Installment.where(folder_id: folder.id)

        installments.each do |installment|
          unless installment_numbers.include?({ id: installment.id, concept: installment.concept })
            installment.update(deleted_at: Time.zone.now)
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
    (job_status = attach_excel_file(excel_rows, job_status, "")) if excel_rows.size > 0

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
        folder_id: "Folio",
        number: "Número de pago",
        concept: "Concepto",
        date: "Fecha",
        capital: "Capital",
        interest: "Interés",
        down_payment: "Enganche"
      }
    end

    def build_installment(row, job_status, index)
      concept = convert_concept(row[:concept])

      number = (row[:number] == "A" || row[:number] == "CE") ? row[:number] : row[:number].to_i

      installment = Installment.find_or_create_by(number: number, concept: concept, folder_id: row[:folder_id].to_i)

      if concepts_with_capital.include?(concept)
        @total_sale -= row[:capital].to_f + row[:down_payment].to_f
      else
        @total_sale -= row[:down_payment].to_f
      end

      job_status.add_progress!("Guardando fila: #{index}...")

      installment.update(date: row[:date],
                        capital: row[:capital],
                        interest: row[:interest],
                        down_payment: row[:down_payment],
                        total: row[:capital].to_f + row[:interest].to_f + row[:down_payment].to_f,
                        debt: concepts_with_capital.include?(concept) ? @total_sale : nil,
                        is_custom: true
                        )
      installment
    end

    def excel_header
      [
        "Folio",
        "Número de pago",
        "Concepto",
        "Fecha",
        "Capital",
        "Interés",
        "Enganche"
      ]
    end

    def convert_concept(concept)
      case concept
      when "Pago inicial"
        "initial_payment"
      when "Enganche"
        "down_payment"
      when "Financiamiento"
        "financing"
      when "Contra entrega"
        "last_payment"
      else
        ""
      end
    end

    def concepts_with_capital
      ["financing", "last_payment"]
    end
end
