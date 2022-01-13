# frozen_string_literal: true

class CommissionUpdateJob < ApplicationJob
  queue_as :low_priority

  def perform(job_status)
    job_status.add_progress!("Generando panel de comisiones ...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode
    columns_with_error = []

    job_status.add_progress!("Leyendo hoja de cálculo...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      sheet = book.sheet(0)

      begin
        sheet.each(header) do |row|
          unless row[:id] == "UUID"
            status = Commission.status_key(row[:status])
            payment_method = PaymentMethod.find_by_name(row[:payment_method])
            commission = Commission.find_by_id(row[:id])

            if commission.present? && status.present?
              job_status.add_progress!("Actualizando comision: #{commission.id}...")
              begin
                date_payment_receipt = row[:date_payment_receipt].present? ? row[:date_payment_receipt].to_date.strftime("%d/%m/%Y") : nil
                commission.update!(status: status, payment_method: payment_method, date_payment_receipt: date_payment_receipt)
              rescue ActiveRecord::RecordInvalid => ex
                Bugsnag.notify(ex)
              end
            end
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

    if columns_with_error.empty?
      job_status.mark_completed!
    end
  rescue StandardError => e
    job_status.mark_failed!(e.to_s)
    job_status.log_error!(e)
    raise e
  end

  private

    def header
      {
        id: "UUID",
        status: "Estatus",
        payment_method: "Método de pago",
        date_payment_receipt: "Fecha de comprobante del pago de comisión"
      }
    end
end
