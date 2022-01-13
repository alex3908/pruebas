# frozen_string_literal: true

require "caxlsx"

class StepHistoricReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, date)
    status.add_progress!("Generando reporte histórico del pipeline...")
    date = date.to_time
    logs_hash = Hash.new
    step_count = Hash.new(0)

    Folder.includes(:step_logs).where("created_at <= (?)", date).each do |folder|
      latest_log = folder.step_logs.where("created_at <= (?)", date).last
      if latest_log.present?
        logs_hash[folder.id] = latest_log
        step_count[latest_log.step.present? ? latest_log.step.name : latest_log.status] += 1
      end
    end

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pipeline") do |sheet|
          sheet.add_row ["SUMATORIA"]
          step_count.each do |step_or_status, amount|
            sheet.add_row [step_or_status.capitalize, amount]
          end

          sheet.add_row [""]
          sheet.add_row ["FOLIO", "PROYECTO", "LOTE", "CLIENTE", "VENDEDOR", "STATUS"]
          # Create entries for each item
          logs_hash.each do |key, log|
            sheet.add_row [
              log.folder.id,
              log.folder.project.name,
              log.folder.lot.full_name,
              log.folder.client.label,
              log.folder.user.label,
              log.step.present? ? log.step.name.upcase : log.status.upcase
            ]
          end
        end

        status.add_progress!("Guardando hoja de cálculo...")
        xlsx_package.serialize(report.path)

        status.add_progress!("Subiendo hoja de cálculo...")
        status.file.attach(io: File.open(report.path), filename: "#{status.file_name}.xlsx")
      end

      status.add_progress!("Limpiando proceso...")

    ensure
      report.close
      report.unlink
    end

    status.mark_completed!
  rescue StandardError => e
    status.mark_failed!(e.to_s)
    status.log_error!(e)
    raise e
  end
end
