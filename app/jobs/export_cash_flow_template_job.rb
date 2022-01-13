# frozen_string_literal: true

require "caxlsx"

class ExportCashFlowTemplateJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando plantilla de flujos de caja ...")

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        wrap_text = xlsx_package.workbook.styles.add_style({ alignment: { horizontal: :center } })
        xlsx_package.workbook.add_worksheet(name: "Amortizaciones") do |sheet|
          sheet.add_row excel_header, style: wrap_text
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
    def excel_header
      [
        "Folio",
        "Correo del Cliente",
        "Correo del Usuario",
        "Sucursal",
        "Método de Pago",
        "Número de Cuenta Bancaria",
        "CLABE Interbancaria",
        "Fecha de Pago",
        "Monto"
      ]
    end
end
