# frozen_string_literal: true

require "caxlsx"

class LotImportJob < ApplicationJob
  include ExportExcelErrors, Exceptions
  queue_as :low_priority

  def perform(job_status, stage)
    job_status.add_progress!("Importando lotes...")
    file = Tempfile.new([job_status.file_name, ".xlsx"], encoding: "ascii-8bit")
    file.binmode
    excel_rows = []
    columns_with_error = []

    job_status.add_progress!("Leyendo hoja de cálculo...")
    begin
      file.write(job_status.file.download)
      file.rewind

      book = Roo::Spreadsheet.open(file.path)
      sheet = book.sheet(0)

      begin
        sheet.each_with_index(headers) do |row, idx|
          next if row[:id] == "UUID"
          lot = build_lot(row, stage)
          job_status.add_progress!("Guardando fila: #{idx}...")
          lot.save!
        rescue ActiveRecord::RecordInvalid, WrongUDID => ex
          job_status.add_progress!("Error fila #{idx}: #{ex.message}")
          excel_rows << build_excel_row(row, ex.message)
        end
      rescue Roo::HeaderRowNotFoundError => ex
        columns_with_error = JSON.parse(ex.message)
        error_message = "Las siguientes columnas no fueron encontradas en el archivo: #{columns_with_error.join(", ")}."
        job_status.add_progress!(error_message)
        job_status.mark_failed!(error_message)
        job_status.log_error!(ex)
      end

      job_status.add_progress!("Limpiando proceso...")
    ensure
      file.close
      file.unlink
    end

    job_status.file.purge if job_status.file.present?
    (job_status = attach_excel_file(excel_rows, job_status, "Lotes")) if excel_rows.size > 0

    if columns_with_error.empty?
      job_status.mark_completed!
    end
  rescue StandardError => e
    job_status.mark_failed!(e.to_s)
    job_status.log_error!(e)
    Bugsnag.notify(e)
  end

  private

    def build_excel_row(original_row, message)
      row = Array.new
      row << original_row[:id]
      row << original_row[:number]
      row << original_row[:label]
      row << original_row[:area]
      row << original_row[:depth]
      row << original_row[:front]
      row << original_row[:price]
      row << original_row[:fixed_price]
      row << original_row[:north]
      row << original_row[:south]
      row << original_row[:east]
      row << original_row[:west]
      row << original_row[:northeast]
      row << original_row[:southeast]
      row << original_row[:northwest]
      row << original_row[:southwest]
      row << original_row[:adjoining_north]
      row << original_row[:adjoining_south]
      row << original_row[:adjoining_east]
      row << original_row[:adjoining_west]
      row << original_row[:adjoining_northeast]
      row << original_row[:adjoining_southeast]
      row << original_row[:adjoining_northwest]
      row << original_row[:adjoining_southwest]
      row << original_row[:planking]
      row << original_row[:folio]
      row << original_row[:undivided]
      row << original_row[:color]
      row << original_row[:owner_name]
      row << original_row[:acquisition_cost]
      row << original_row[:market_price]
      row << original_row[:exchange_rate]
      row << original_row[:vocation]
      row << original_row[:descriptive_status]
      row << original_row[:blocks]
      row << original_row[:geographic_location]
      row << original_row[:ownership_percent]
      row << original_row[:coowners]
      row << original_row[:liquidity]
      row << original_row[:colloquial_name]
      row << original_row[:identification_name]
      row << message
      row
    end

    def headers
      {
        id: "UUID",
        number: "Número",
        label: "Clasificador",
        area: "Área",
        depth: "Fondo",
        front: "Frente",
        price: "Precio adicional por m²",
        fixed_price: "Precio fijo final",
        north: "Norte en metros",
        south: "Sur en metros",
        east: "Este en metros",
        west: "Oeste en metros",
        northeast: "Noreste en metros",
        southeast: "Sureste en metros",
        northwest: "Noroeste en metros",
        southwest: "Suroeste en metros",
        adjoining_north: "Colinda al Norte con",
        adjoining_south: "Colinda al Sur con",
        adjoining_east: "Colinda al Este con",
        adjoining_west: "Colinda al Oeste con",
        adjoining_northeast: "Colinda al Noreste con",
        adjoining_southeast: "Colinda al Sureste con",
        adjoining_northwest: "Colinda al Noroeste con",
        adjoining_southwest: "Colinda al Suroeste con",
        planking: "Tablaje",
        folio: "Folio catastral",
        undivided: "Proindiviso",
        color: "Color de Disponibilidad",
        owner_name: "Nombre del propietario",
        acquisition_cost: "Valor de adquisición",
        market_price: "Valor de mercado",
        exchange_rate: "Tipo de cambio",
        vocation: "Vocación",
        descriptive_status: "Estatus",
        blocks: "Bloques",
        geographic_location: "Ubicación geográfica",
        ownership_percent: "Porcentaje de propiedad",
        coowners: "Copropietarios",
        liquidity: "Liquidez",
        colloquial_name: "Nombre coloquial",
        identification_name: "Nombre de identificación",
      }
    end

    def build_lot(row, stage)
      lot = Lot.find_by(id: row[:id])
      if lot && lot.stage != stage
        raise WrongLotUDID.new("La unidad identificada con UDID #{row[:id]} no pertenece a esta archivo")
      end

      lot = Lot.find_or_initialize_by(id: row[:id], stage: stage)
      lot.assign_attributes(row.except(:id))
      lot
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
        "Área Común Condominal",
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
        "Observaciones"
      ]
    end
end
