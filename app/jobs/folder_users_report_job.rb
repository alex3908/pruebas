# frozen_string_literal: true

require "caxlsx"

class FolderUsersReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, folder_user_ids)
    status.add_progress!("Generando reporte de pagos...")
    folder_users = FolderUser.includes(:role, :folder, :folder_user_concept, user: [:branch]).where(id: folder_user_ids)

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Responsables") do |sheet|
          sheet.add_row generate_header
          folder_users.each { |folder_user| sheet.add_row(generate_row(folder_user)) }
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
    def generate_row(folder_user)
      [
        folder_user.user.id,
        folder_user.user.label,
        folder_user.role.name,
        folder_user.user.branch.name,
        folder_user.folder.id,
        folder_user.folder_user_concept.name,
        folder_user.percentage.to_s + "%",
        folder_user.amount,
        folder_user.commissions.count
      ]
    end

    def generate_header
      [
        "ID DEL USUARIO",
        "NOMBRE DEL RESPONSABLE",
        "ROL",
        "SUCURSAL",
        "FOLIO DEL EXPEDIENTE",
        "CONCEPTO",
        "PORCENTAJE",
        "MONTO",
        "CANTIDAD DE COMISIONES"
      ]
    end
end
