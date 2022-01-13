# frozen_string_literal: true

require "caxlsx"
class DispersionCommisionReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, commission_ids)
    commissions = Commission.where(id: commission_ids)
    status.add_progress!("Generando reporte de comisiones...")
    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Dispersión de comisiones") do |sheet|
          title = sheet.styles.add_style(b: true, alignment: { horizontal: :center })
          sheet.merge_cells("A1:M1")
          sheet.merge_cells("N1:P1")
          sheet.auto_filter = "A2:P2"

          sheet.add_row(classifiers, style: title)
          sheet.add_row(header, style: title)
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

    def classifiers
      [
        "INFORMACIÓN BÁSICA",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "DATOS DE PAGO"
      ]
    end

    def header
      [
        "CÓDIGO EMPLEADO",
        "NOMBRES",
        "APELLIDOS",
        "FECHA DE NACIMIENTO (DÍA)",
        "FECHA DE NACIMIENTO (MES)",
        "FECHA DE NACIMIENTO (AÑO)",
        "GÉNERO",
        "RFC",
        "CURP",
        "EMAIL DE ENVÍO DE RECIBO IAS",
        "MONTO A TRANSFERIR",
        "ESTADO",
        "MÉTODO DE PAGO",
        "BANCO",
        "NÚMERO DE CUENTA",
        "CLABE"
      ]
    end

    def generate_row(commission)
      user = commission.folder_user.user
      bank_account = user.principal_bank_account
      [
        user.id,
        user.first_name,
        user.last_name,
        user.birthdate&.strftime("%d"),
        user.birthdate&.strftime("%m"),
        user.birthdate&.strftime("%Y"),
        user.get_gender,
        user.written_rfc,
        user.written_curp,
        user.email,
        commission.amount,
        commission.status_label,
        commission.payment_method&.name,
        bank_account&.bank,
        bank_account&.account_number,
        bank_account&.clabe
      ]
    end
end
