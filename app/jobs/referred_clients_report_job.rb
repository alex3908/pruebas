# frozen_string_literal: true

require "caxlsx"

class ReferredClientsReportJob < ApplicationJob
  include ActionView::Helpers::NumberHelper, DateHelper
  queue_as :low_priority

  def perform(status, params)
    status.add_progress!("Generando Reporte de Clientes Referidos...")

    referred_clients = ReferredClient.all
    referred_clients = referred_clients.where("created_at >= ?", params[:from_date].to_time.strftime("%Y-%m-%d %l:%M:%S")) if params[:from_date].present?
    referred_clients = referred_clients.where("created_at <= ?", params[:to_date].to_time.strftime("%Y-%m-%d %l:%M:%S")) if params[:to_date].present?

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Clientes Referidos") do |sheet|
          centered_text = sheet.styles.add_style(alignment: { horizontal: :center })
          sheet.add_row generate_header, style: centered_text
          referred_clients.each { |referred_client| sheet.add_row generate_row(referred_client), style: centered_text }
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

    def generate_row(rc)
      referred_client = rc.referred_client
      client = rc.client

      [
          only_date(rc.created_at),
          client.label,
          client.email,
          referred_client.label,
          referred_client.email
      ]
    end

    def generate_header
      ["Fecha de referido", "Usuario referido", "Email de referido", "Usuario invitado", "Email de invitado"]
    end
end
