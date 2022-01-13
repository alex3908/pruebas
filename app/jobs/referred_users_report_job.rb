# frozen_string_literal: true

require "caxlsx"

class ReferredUsersReportJob < ApplicationJob
  include ActionView::Helpers::NumberHelper, DateHelper
  queue_as :low_priority

  def perform(status, params)
    status.add_progress!("Generando reporte...")
    status.add_progress!("Creando hoja de cálculo...")

    referred_users = Referent.all
    referred_users = referred_users.where("created_at >= ?", params[:from_date].to_time.strftime("%Y-%m-%d 00:00:00")) if params[:from_date].present?
    referred_users = referred_users.where("created_at <= ?", params[:to_date].to_time.strftime("%Y-%m-%d 23:59:59")) if params[:to_date].present?

    status.add_progress!("Creando hoja de cálculo...")

    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")
      status.add_progress!("Guardando hoja de cálculo...")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Usuarios Referidos") do |sheet|
          centered_text = sheet.styles.add_style(alignment: { horizontal: :center })
          sheet.add_row generate_header, style: centered_text
          referred_users.each { |reffered_user| sheet.add_row generate_row(reffered_user), style: centered_text }
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

    def generate_row(reffered_user)
      referrer = reffered_user.referrer
      invited = reffered_user.invited

      [
        only_date(reffered_user.created_at),
        referrer.label,
        referrer.email,
        referrer.role&.name,
        invited.label,
        invited.email,
        invited.role&.name,
      ]
    end

    def generate_header
      [
        "Fecha de referencia",
        "Nombre usuario referido",
        "Email usuario referido",
        "Rol usuario referido",
        "Nombre usuario invitado",
        "Email usuario invitado",
        "Rol usuario invitado",
      ]
    end
end
