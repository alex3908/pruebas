# frozen_string_literal: true

require "caxlsx"

class FolderImportTemplateJob < ApplicationJob
  queue_as :low_priority
  include DateHelper

  def perform(status, folder_ids)
    status.add_progress!("Generando plantilla de expedientes...")
    folders = Folder.includes(:payment_scheme, :client, :client_2, :client_3, :client_4, :client_5, :client_6, [lot: [stage: :phase]], [user: :structure]).where(id: folder_ids)

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Expedientes") do |sheet|
          sheet.add_row(columns)

          folders.each do |folder|
            sheet.add_row(generate_row(folder))
          end

          status.add_progress!("Guardandgo hoja de cálculo...")
          xlsx_package.serialize(report.path)

          status.add_progress!("Subiendo hoja de cálculo...")
          status.file.attach(io: File.open(report.path), filename: "#{status.file_name}.xlsx")
        end

        status.add_progress!("Limpiando proceso...")
      end

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

  def generate_row(folder)
    [
      folder.user.email,
      folder.user.first_name,
      folder.user.last_name,
      folder.user.phone,
      folder.user.branch.name,
      only_date(folder.user.birthdate),
      folder.user.gender == "Masculino" ? "M" : "F",
      folder.user.written_rfc,
      folder.user.written_curp,
      folder.user.role.name,
      folder.client.name,
      folder.client.first_surname,
      folder.client.second_surname,
      folder.client.main_phone,
      folder.client.optional_phone,
      folder.client.email,
      folder.client.get_gender == "Masculino" ? "M" : "F",
      folder.client.physical? ? "Física" : "Moral",
      folder.project.name,
      folder.phase.name,
      folder.stage.name,
      folder.lot.name,
      folder.lot.label,
      folder.lot.id,
      folder.status_label,
      only_date(folder.start_date),
      folder.payment_scheme.initial_payment,
      folder.payment_scheme.discount,
      folder.payment_scheme.total_payments,
      folder.payment_scheme.down_payment_finance,
      folder.payment_scheme.down_payment,
      folder.payment_scheme.buy_price,
      folder.payment_scheme.first_payment,
      folder.payment_scheme.start_installments,
      folder.payment_scheme.promotion_name,
      folder.payment_scheme.promotion_discount,
      folder.payment_scheme.promotion_operation,
      folder.payment_scheme.opening_commission,
      folder.buyer,
      ""
    ]
  end

  def columns
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
end
