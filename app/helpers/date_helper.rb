# frozen_string_literal: true

module DateHelper
  # 13/03/2020 09:54 AM
  def date_hour(date)
    return "" if date.nil?
    I18n.localize date, format: :date_hour
    end

  # 13/03/2020
  def only_date(date)
    return "" if date.nil?
    I18n.localize date, format: :only_date
  end

  # 09:54 AM
  def only_hour(date)
    return "" if date.nil?
    I18n.localize date, format: :only_hour
  end

  # 13 de Marzo de 2020 09:53 AM
  def human_full(date)
    return "" if date.nil?
    I18n.localize date, format: :human_full
  end
end
