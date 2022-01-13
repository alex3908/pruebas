# frozen_string_literal: true

module ExportExcelErrors
  def build_excel_row(values, message)
    row = values.each_value.to_a
    row << message
    row
  end

  def attach_excel_file(rows, status, woork_sheet = "Datos")
    status.add_progress!("Creando hoja de cálculo con filas erróneas...")
    begin
      begin
        file_name = status.file_name << "--con-observaciones"
        report = Tempfile.new([file_name, ".xlsx"], encoding: "ascii-8bit")
        status.add_progress!("Guardando hoja de cálculo...")
        Axlsx::Package.new do |xlsx_package|
          xlsx_package.workbook.add_worksheet(name: woork_sheet) do |sheet|
            sheet.add_row excel_header
            rows.each { |row| sheet.add_row(row) }
          end

          status.add_progress!("Guardando hoja de cálculo...")
          xlsx_package.serialize(report.path)

          status.add_progress!("Subiendo hoja de cálculo...")
          status.file.attach(io: File.open(report.path), filename: "#{file_name }.xlsx")
        end

        status.add_progress!("Limpiando proceso...")
      ensure
        report.close
        report.unlink
      end

    rescue StandardError => e
      raise e
    end
    status
  end
end
