# frozen_string_literal: true

require "caxlsx"

class ExportFolderTemplateJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando plantilla de expedientes...")
    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        wrap_text = xlsx_package.workbook.styles.add_style({ alignment: { horizontal: :center } })
        xlsx_package.workbook.add_worksheet(name: "Expedientes") do |sheet|
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
        "Correo del Usuario",
        "Nombre del Usuario",
        "Apellido del Usuario",
        "Teléfono del Usuario",
        "Sucursal del Usuario",
        "Fecha de Cumpleaños del Usuario",
        "Género del Usuario",
        "RFC del Usuario",
        "CURP del Usuario",
        "Rol del Usuario",
        "Nombre del Cliente",
        "Primer Apellido del Cliente",
        "Segundo Apellido del Cliente",
        "Teléfono Principal del Cliente",
        "Teléfono Opcional del Cliente",
        "Correo del Cliente",
        "Género del Cliente",
        "Tipo de Persona del Cliente",
        "Nombre del Proyecto",
        "Nombre de la Fase",
        "Nombre de la Etapa",
        "Número del Lote",
        "Clasificador del Lote",
        "ID de Lote",
        "Estado del Expediente",
        "Fecha Inicial",
        "Apartado",
        "Descuento",
        "Total de Pagos",
        "Financiamiento del Enganche",
        "Saldo del Enganche",
        "Precio por m2",
        "Dias para Pago de Enganche",
        "Meses para Pago de Financiamiento",
        "Nombre de la Promoción",
        "Porcentaje de Promoción",
        "Formula de la Promoción",
        "Comisión por apertura",
        "Tipo de Comprador",
        "Observaciones"
      ]
    end

    def drop_down_concepts(concepts)
      { type: :list,
        formula1: %{"#{concepts.map(&:name).join(", ")}"},
        showDropDown: false,
        prompt: "Ingresa un concepto"
      }
    end
end
