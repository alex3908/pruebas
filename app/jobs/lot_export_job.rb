# frozen_string_literal: true

require "caxlsx"

class LotExportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, lots_ids)
    status.add_progress!("Generando reporte de lotes ...")
    lots = Lot.where(id: lots_ids)

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Lotes") do |sheet|
          sheet.add_row excel_header
          lots.each { |lot| sheet.add_row(generate_row(lot)) }
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

    def generate_row(lot)
      row = []
      row << lot.id
      row << lot.number
      row << lot.label
      row << lot.area
      row << lot.depth
      row << lot.front
      row << lot.price
      row << lot.fixed_price
      row << lot.north
      row << lot.south
      row << lot.east
      row << lot.west
      row << lot.northeast
      row << lot.southeast
      row << lot.northwest
      row << lot.southwest
      row << lot.adjoining_north
      row << lot.adjoining_south
      row << lot.adjoining_east
      row << lot.adjoining_west
      row << lot.adjoining_northeast
      row << lot.adjoining_southeast
      row << lot.adjoining_northwest
      row << lot.adjoining_southwest
      row << lot.planking
      row << lot.folio
      row << lot.undivided
      row << lot.fixed_price
      row << lot.color
      row << lot.owner_name
      row << lot.acquisition_cost
      row << lot.market_price
      row << lot.exchange_rate
      row << lot.vocation
      row << lot.descriptive_status
      row << lot.blocks
      row << lot.geographic_location
      row << lot.ownership_percent
      row << lot.coowners
      row << lot.liquidity
      row << lot.colloquial_name
      row << lot.identification_name
      row
    end

    def excel_header
      [
        "UUID",
        "Número",
        "Clasificador",
        "Área",
        "Fondo",
        "Frente",
        "Precio adicional por m²",
        "Precio fijo final",
        "Norte en metros",
        "Sur en metros",
        "Este en metros",
        "Oeste en metros",
        "Noreste en metros",
        "Sureste en metros",
        "Noroeste en metros",
        "Suroeste en metros",
        "Colinda al Norte con",
        "Colinda al Sur con",
        "Colinda al Este con",
        "Colinda al Oeste con",
        "Colinda al Noreste con",
        "Colinda al Sureste con",
        "Colinda al Noroeste con",
        "Colinda al Suroeste con",
        "Tablaje",
        "Folio catastral",
        "Proindiviso",
        "Precio fijo",
        "Color de Disponibilidad",
        "Nombre del propietario",
        "Valor de adquisición",
        "Valor de mercado",
        "Tipo de cambio",
        "Vocación",
        "Estatus",
        "Bloques",
        "Ubicación geográfica",
        "Porcentaje de propiedad",
        "Copropietarios",
        "Liquidez",
        "Nombre coloquial",
        "Nombre de identificación",
      ]
    end
end
