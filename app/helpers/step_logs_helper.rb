# frozen_string_literal: true

module StepLogsHelper
  def step_log_header(log)
    if log.active? && !log.step.is_last_one? || log.canceled?
      if log.user.present?
        "El usuario #{tag.strong(log.user.label, class: "text-info")}".html_safe
      else
        tag.strong(@server_name, class: "text-info").html_safe
      end
    end
  end

  def step_log_body(log, index)
    if log.active? && log.step.is_first_one? && index == 0
      "inició la venta de #{tag.strong(log.folder.lot.full_name)} para el cliente #{log.folder.client.label}, ".html_safe
    elsif log.active? && log.step.is_first_one? && index != 0
      "rechazó el expediente, "
    elsif log.active? && !log.step.is_last_one?
      "envió el expediente #{log.folder.id} (#{log.folder.client.label}) a #{log.step.name}, "
    elsif log.active? && log.step.is_last_one?
      if log.user.present?
        "La venta fue concluida por el usuario #{tag.strong(log.user.label, class: "text-info")}, ".html_safe
      else
        "La venta fue concluida por #{tag.strong(@server_name, class: "text-info text-lowercase")}, ".html_safe
      end
    elsif log.canceled?
      "canceló el expediente"
    elsif log.expired?
      "El servidor expiró el expediente"
    end
  end

  def step_log_timestamp(log)
    "el día #{log.moved_at.strftime("%d/%m/%Y")} a las #{log.moved_at.strftime("%I:%M:%S %p")}"
  end

  def step_log_icon(log, index)
    if log.active? && log.step.is_first_one?
      index == 0 ? "fa-plus" : "fa-repeat"
    elsif log.active? && !log.step.is_last_one?
      "fa-search"
    elsif log.active? && log.step.is_last_one?
      "fa-check"
    elsif log.canceled?
      "fa-trash"
    end
  end

  def time_in_step_log(log)
    "Hace #{distance_of_time_in_words(Time.zone.now, log.moved_at, { accumulate_on: :days, highest_measure_only: true })}"
  end
end
