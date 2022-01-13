# frozen_string_literal: true

require "caxlsx"

class ExportAmortizationTemplateJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando plantilla de amortización ...")

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        wrap_text = xlsx_package.workbook.styles.add_style({ alignment: { horizontal: :center } })
        xlsx_package.workbook.add_worksheet(name: "Amortizaciones") do |sheet|
          sheet.add_row excel_header, style: wrap_text
          sheet.add_row [3, "A", "Pago inicial", "2021-04-04", nil, nil, "5000.00"], style: wrap_text
          sheet.add_row ["Folio del expediente : Valor entero ",
                         "Número de pago : Valor entero, 'A' para pago inicial, 'CE' para pago inicial",
                         "Concepto de pago : Cadena [Pago inicial, Enganche, Financiamiento, Contra entrega]",
                         "Fecha de pago : Cadena formato YYYY-MM-DD",
                         "Valor de capital : Flotante a dos dígitos a la derecha",
                         "Interés : flotante a dos dígitos a la derecha ",
                         "Enganche : flotante a dos dígitos a la derecha"], style: wrap_text
          sheet.add_row([nil, nil, nil, nil, nil, nil, nil])
          sheet.add_row [4, "A", "Pago inicial", "2022-06-03", nil, nil, "800.00"], style: wrap_text
          sheet.add_row ["Folio del expediente : Valor entero ",
              "Número de pago : Valor entero, 'A' para pago inicial, 'CE' para pago inicial",
              "Concepto de pago : Cadena [Pago inicial, Enganche, Financiamiento, Contra entrega]",
              "Fecha de pago : Cadena formato YYYY-MM-DD",
              "Valor de capital : Flotante a dos dígitos a la derecha",
              "Interés : flotante a dos dígitos a la derecha ",
              "Enganche : flotante a dos dígitos a la derecha"], style: wrap_text

          sheet.add_data_validation("C2:C4", drop_down_config)
          sheet.add_data_validation("C6:C8", drop_down_config)
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
        "Número de pago",
        "Concepto",
        "Fecha",
        "Capital",
        "Interés",
        "Enganche"
      ]
    end
    def drop_down_config
      { type: :list,
        formula1: "Pago inicial, Enganche, Financiamiento, Contra entrega",
        showDropDown: false
      }
    end
end
