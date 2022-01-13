# frozen_string_literal: true

require "caxlsx"

class ImportClientUserJob < ApplicationJob
  include ExportExcelErrors
  queue_as :low_priority

  @job_status = nil

  def perform(job_status)
    @job_status = job_status

    job_status.add_progress!("Importando Responsables de clientes...")
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
          next if row[:client_email] == "CLIENTE"
          next if row[:user_email].blank? || row[:client_email].blank? || row[:concept].blank?

          client = Client.find_by!(email: row[:client_email].to_s.strip)
          client_user_concept = ClientUserConcept.find_by!(name: row[:concept].to_s.strip)
          user = User.find_by!(email: row[:user_email].to_s.strip)

          ClientUser.create!(client: client, user: user, client_user_concept: client_user_concept)

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
        client_email: "CLIENTE",
        user_email: "USUARIOS DEL SISTEMA",
        concept: "CONCEPTO"
      }
    end

    def excel_header
      [
        "CLIENTE",
        "USUARIOS DEL SISTEMA",
        "CONCEPTO",
        "OBSERVACIONES"
      ]
    end
end
