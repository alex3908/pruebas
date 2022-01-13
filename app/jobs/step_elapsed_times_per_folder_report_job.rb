# frozen_string_literal: true

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::DateHelper
include ActionView::Helpers::TextHelper

require "caxlsx"

class StepElapsedTimesPerFolderReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando reporte de tiempos por expediente del pipeline...")

    folders_summary = Hash.new
    Folder.not_in_sale.each do |folder|
      elapsed_times = Hash.new(0)
      logs_arr = folder.step_logs.order(moved_at: :asc)
      logs_arr.each_with_index do |log, index|
        hash_key = log.step.name if log.step.present?
        hash_key = log.status unless log.step.present?

        hash_value = logs_arr[index + 1].moved_at if logs_arr[index + 1].present?
        hash_value = Time.zone.now unless logs_arr[index + 1].present?

        elapsed_times[hash_key] += hash_value - log.moved_at
      end

      # elapsed_times needs to be integer to add more elapsed times to same hash entry
      # This hash any type, so the sum of times can be converted to string with distance_of_time
      elapsed_clean_times = Hash.new
      elapsed_times.each do |step_name, elapsed_time|
        elapsed_clean_times[step_name] = distance_of_time(elapsed_time)
      end
      folders_summary[folder.id] = { folder: folder, elapsed_clean_times: elapsed_clean_times }
    end

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pipeline") do |sheet|
          # Create entries for each item
          folders_summary.each do | key, folder_summary |
            sheet.add_row [ "Lote:", folder_summary[:folder].lot.full_name, "Proyecto:", folder_summary[:folder].lot.stage.phase.project.name ]
            sheet.add_row [ "Asesor:", folder_summary[:folder].user.label, "Cliente:", folder_summary[:folder].client.label ]
            sheet.add_row [ "======" ]
            sheet.add_row [ "Folio" ] + folder_summary[:elapsed_clean_times].keys
            sheet.add_row [ key ] + folder_summary[:elapsed_clean_times].values
            sheet.add_row [ " " ]
            sheet.add_row [ " " ]
            sheet.add_row [ " " ]
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
