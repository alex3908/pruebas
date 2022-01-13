# frozen_string_literal: true

require "caxlsx"

class CommissionReportJob < ApplicationJob
  include ActionView::Helpers::NumberHelper
  queue_as :low_priority

  def perform(status, commissions_ids)
    status.add_progress!("Generando panel de comisiones ...")
    commissions = Commission.includes(:installment, folder_user: [user: :bank_accounts, folder: [ lot: [stage: [phase: :project]]]]).where(id: commissions_ids)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Comisiones") do |sheet|
          sheet.add_row generate_header
          commissions.each { |commission| sheet.add_row generate_row(commission), types: generate_types }
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

    def generate_row(commission)
      row = Array.new
      folder_user = commission.folder_user
      folder = folder_user.folder
      user = folder_user.user
      lot = folder_user.folder.lot
      stage = lot.stage
      phase = stage.phase
      project = phase.project
      installment = commission.installment
      bank_account = user.principal_bank_account

      # Basic user info
      row << user.id
      row << user.first_name
      row << user.last_name
      row << user.birthdate&.day
      row << user.birthdate&.month
      row << user.birthdate&.year
      row << user.get_gender
      row << user.written_rfc
      row << user.written_curp
      row << user.email

      # Bank details
      row << commission.payment_method&.name
      row << bank_account&.bank
      row << bank_account&.clabe
      row << bank_account&.account_number

      # Commission details
      row << commission.sale_total
      row << commission.status_label
      row << "#{commission.installment.concept_label} #{commission.get_numeration}"
      row << project.name
      row << phase.name
      row << stage.name
      row << lot.name
      row << commission.payment.cash_flow.folio
      row << installment.concept
      row << installment.date
      row << folder.user.label
      row << folder.id
      row << commission.date.to_date
      row << folder_user.folder_user_concept.name
      row << commission.folder_user.percentage
      row << commission.amount
      row << (commission.paid? ? commission.amount : 0)
      row << (commission.paid? ? 0 : commission.amount)
      row << (commission.date_payment_receipt.nil? ? nil : commission.date_payment_receipt)
      row << commission.id

      row
    end

    def generate_types
      [:integer, :string, :string, :integer, :integer, :integer, :string, :string, :string, :string, :string, :string,
        :string, :string, :float, :string, :float, :string, :string, :string, :string, :string, :string, :date, :string,
        :integer, :date, :string, :float, :float, :float, :float, :date, :integer]
    end

    def generate_header
      ["Código Empleado", "Nombres", "Apellidos", "Fecha de Nacimiento (Día)", "Fecha de Nacimiento (Mes)",
       "Fecha de Nacimiento (Año)", "Género", "RFC", "CURP", "Email de envio de recibo de IAS", "Método de pago",
       "Banco", "CLABE", "Cuenta", "Monto total de la venta", "Estatus", "Modo de pago", "Proyecto", "Etapa",
       "Privada", "Unidad", "Flujo de Caja", "Concepto", "Fecha del pago de letra", "Nombre del dueño de la venta", "Folio de Expediente",
       "Fecha", "Tipo", "Porcentaje", "Monto", "Monto pagado", "Monto pendiente",
       "Fecha de comprobante del pago de comisión", "UUID"]
    end
end
