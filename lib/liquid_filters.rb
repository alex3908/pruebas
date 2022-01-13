# frozen_string_literal: true

module LiquidFilters
  def number_to_currency_text(currency)
    integer = currency.to_i
    decimal = currency - integer
    decimal = (decimal.round(2) * 100.0).to_i
    cents_words = decimal < 10 ? "0#{decimal}" : decimal
    price_words = I18n.with_locale(:es) { integer.to_words }

    "#{price_words} pesos #{cents_words}/100 MN"
  end

  def money_text(currency)
    integer = currency.to_i
    decimal = currency - integer
    decimal = (decimal.round(2) * 100.0).to_i
    cents_words = decimal < 10 ? "0#{decimal}" : decimal
    price_words = I18n.with_locale(:es) { integer.to_words }

    "#{price_words} pesos #{cents_words}/100 MN"
  end

  def money(currency)
    number_helper.number_to_currency(currency, precision: 2)
  end

  def localize_date(date, format)
    I18n.localize(date, format: format)
  end

  def capitalize(str)
    str.capitalize
  end

  def titleize(str)
    str.titleize
  end

  private
    def number_helper
      @number_helper ||= Class.new do
        include ActionView::Helpers::NumberHelper
      end.new
    end
end
