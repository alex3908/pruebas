# frozen_string_literal: true

require "caxlsx"

class ExportClientUserTemplateJob < ApplicationJob
  queue_as :low_priority

  def perform(status)
    status.add_progress!("Generando plantilla de responsables de clientes...")
    status.add_progress!("Creando hoja de cálculo...")

    client_user_concepts = ClientUserConcept.all


    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        wrap_text = xlsx_package.workbook.styles.add_style({ alignment: { horizontal: :center } })
        xlsx_package.workbook.add_worksheet(name: "Responsables de clientes") do |sheet|
          sheet.add_row excel_header, style: wrap_text
          sheet.add_row ["tristan@stanton.net", "hollie@toy-pollich.io"], style: wrap_text
          sheet.add_row ["", "glendora.bernier@tremblay.com"], style: wrap_text
          sheet.add_row ["", "enola@blick.io"], style: wrap_text
          sheet.add_row([nil, nil])
          sheet.add_row ["hollie@toy-pollich.io", "glendora.bernier@tremblay.com"], style: wrap_text
          sheet.add_row ["", "enola@blick.io"], style: wrap_text

          sheet.add_data_validation("C2:C4", drop_down_concepts(client_user_concepts))
          sheet.add_data_validation("C6:C7", drop_down_concepts(client_user_concepts))
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
        "CLIENTE",
        "USUARIOS DEL SISTEMA",
        "CONCEPTO"
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
