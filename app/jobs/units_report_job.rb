# frozen_string_literal: true

require "caxlsx"

class UnitsReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, stage_ids)
    status.add_progress!("Generando reporte de pagos...")
    stages = Stage.includes(phase: :project).where(id: stage_ids)

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Unidades") do |sheet|
          sheet.add_row generate_header
          stages.each_with_index { |stage, idx| sheet.add_row(generate_row(stage, idx)) }
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

  private
    def generate_row(stage, idx)
      total_lots = Lot.where(stage: stage).count
      reserved_lots = Lot.select(:status).where(stage: stage, status: 1).count
      locked_lots = Lot.select(:status).where(stage: stage, status: 3).count
      available_lots = Lot.select(:status).where(stage: stage, status: 0).count
      [
        idx + 1,
        stage.phase.project.name,
        stage.phase.name,
        stage.name,
        total_lots,
        stage.sold_lots,
        locked_lots,
        reserved_lots,
        available_lots
      ]
    end

    def generate_header
      settings = Setting.where(key: ["project_singular", "phase_singular", "stage_singular", "lot_singular"])
      project_singular = settings.find { |s| s.key == "project_singular" }.try(:convert)
      phase_singular = settings.find { |s| s.key == "phase_singular" }.try(:convert)
      stage_singular = settings.find { |s| s.key == "stage_singular" }.try(:convert)
      lot_plural = settings.find { |s| s.key == "lot_singular" }.try(:convert)
      [
        "NÚMERO",
        project_singular,
        phase_singular,
        stage_singular,
        "#{lot_plural} Totales",
        "#{lot_plural} Vendidos",
        "#{lot_plural} Bloqueados",
        "#{lot_plural} en proceso de venta",
        "#{lot_plural} disponibles en CRM"
      ]
    end
end
