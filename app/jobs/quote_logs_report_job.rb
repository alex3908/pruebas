# frozen_string_literal: true

require "caxlsx"

class QuoteLogsReportJob < ApplicationJob
  queue_as :low_priority

  def perform(status, filter_params)
    quote_log_ids = QuoteLog.set_params(filter_params, "quote_logs.created_at", "desc").pluck(:id)

    status.add_progress!("Generando reporte de cotizaciones...")
    quote_logs = QuoteLog.includes(:user, :client, :folder).where(id: quote_log_ids).order(id: :asc)

    status.add_progress!("Creando hoja de cálculo...")
    begin
      report = Tempfile.new([status.file_name, ".xlsx"], encoding: "ascii-8bit")

      Axlsx::Package.new do |xlsx_package|
        xlsx_package.workbook.add_worksheet(name: "Tickets de pago") do |sheet|
          sheet.add_row generate_header
          quote_logs.each { |quote_log| sheet.add_row(generate_row(quote_log)) }
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
    def generate_row(quotation)
      email_delivered = quotation.email_delivered ? "Si" : "No"
      downloaded = quotation.downloaded ? "Si" : "No"
      folio = quotation.folder.present? ? quotation.folder.id : "N/A"
      status = quotation.folder.present? ? quotation.folder.status_label : "N/A"

      [
        quotation.lot.project.name,
        quotation.lot.phase.name,
        quotation.lot.stage.name,
        quotation.lot.name,
        quotation.user.label,
        quotation.user.email,
        quotation.client.label,
        quotation.client.email,
        quotation.client.lead_source&.name,
        email_delivered,
        downloaded,
        folio,
        status,
        quotation.creation_date,

      ]
    end

    def generate_header
      [
        I18n.t("activerecord.attributes.quote_log.project"),
        I18n.t("activerecord.attributes.quote_log.phase"),
        I18n.t("activerecord.attributes.quote_log.stage"),
        I18n.t("activerecord.attributes.quote_log.lot"),
        I18n.t("activerecord.attributes.quote_log.user_name"),
        I18n.t("activerecord.attributes.quote_log.user_email"),
        I18n.t("activerecord.attributes.quote_log.client_name"),
        I18n.t("activerecord.attributes.quote_log.client_email"),
        I18n.t("activerecord.attributes.quote_log.lead_source"),
        I18n.t("activerecord.attributes.quote_log.email_delivered"),
        I18n.t("activerecord.attributes.quote_log.downloaded"),
        I18n.t("activerecord.attributes.quote_log.folio"),
        I18n.t("activerecord.attributes.quote_log.status"),
        I18n.t("activerecord.attributes.quote_log.creation_date")
      ]
    end
end
