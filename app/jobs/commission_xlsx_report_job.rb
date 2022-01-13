# frozen_string_literal: true

require "caxlsx"
class CommissionXlsxReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, commission_ids)
    commissions = Commission.where(id: commission_ids)
    status.add_progress!("Generando reporte de comisiones...")
    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Comisiones") do |sheet|
          sheet.add_row(generate_header)
          commissions.each do |commission|
            sheet.add_row(generate_row(commission))
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

  private
    def generate_header
      [
        "FOLIO DEL EXPEDIENTE",
        "NOMBRE COMPLETO DEL COMISIONADO",
        "CORREO ELECTRÓNICO",
        "TIPO DE COMISIÓN",
        "MONTO DE COMISIÓN TOTAL",
        "PORCENTAJE DE COMISIÓN"
      ]
    end

    def generate_row(commission)
      [
        commission.folder_user.folder.id,
        commission.folder_user.user.label,
        commission.folder_user.user.email,
        commission.folder_user.folder_user_concept.name,
        commission.amount,
        commission.folder_user.percentage.to_s + "%"
      ]
    end
end
