# frozen_string_literal: true

module QuoteLogsHelper
  def quote_log_icon(log)
    return "fa-calculator" unless log.folder.present?
    "fa-address-book"
  end

  def quote_header(log)
    "El usuario #{tag.strong(log.user.label, class: "text-info")}".html_safe
  end

  def quote_body(log)
    if log.folder.present?
      "hizo una reserva de #{tag.strong(log.lot.full_path(" / "))}".html_safe
    else
      "hizo una cotización de #{tag.strong(log.lot.full_path(" / "))}".html_safe
    end
  end

  def quote_actions(log)
    actions = []

    actions << "Se ha enviado por correo la cotización." if log.email_delivered?

    actions << "Se ha descargado la cotización." if log.downloaded?

    actions
  end

  def quote_timestamp(log)
    "el día #{only_date(log.created_at)} a las #{only_hour(log.created_at)}."
  end

  def time_label(date)
    "Hace #{distance_of_time_in_words(Time.zone.now, date, { accumulate_on: :days, highest_measure_only: true })}"
  end
end
