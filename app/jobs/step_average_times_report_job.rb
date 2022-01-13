# frozen_string_literal: true

include ActionView::Helpers::NumberHelper
include ActionView::Helpers::DateHelper
include ActionView::Helpers::TextHelper

require "caxlsx"

class StepAverageTimesReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando reporte de tiempos promedio del pipeline...")

    sum_of_elapsed_times = Hash.new(0)
    number_of_folders = Hash.new(0)
    Folder.not_in_sale.each do |folder|
      logs_arr = folder.step_logs.order(moved_at: :asc)
      logs_arr.each_with_index do |log, index|
        hash_key = log.step.present? ? log.step.name : log.status
        elapsed_time = (logs_arr[index + 1].present? ? logs_arr[index + 1].moved_at : Time.zone.now) - log.moved_at

        sum_of_elapsed_times[hash_key] += elapsed_time
        number_of_folders[hash_key] += 1 if elapsed_time > 0
      end
    end
    # sum_of_elapsed_times needs to be integer to add more elapsed times to same hash entry
    # This hash any type, so the sum of times can be converted to string with distance_of_time
    sum_of_clean_times = sum_of_elapsed_times.inject({}) { |new_hash, (key, value)| new_hash[key] = distance_of_time(value / number_of_folders[key]); new_hash }

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([ status.file_name, ".xlsx" ], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Pipeline") do |sheet|
          # Create entries for each item
          sheet.add_row sum_of_clean_times.keys
          sheet.add_row sum_of_clean_times.values
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
