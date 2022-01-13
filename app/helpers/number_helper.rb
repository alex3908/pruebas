# frozen_string_literal: true

module NumberHelper
  def text_to_decimal(text, number_decimals)
    number_with_precision(text.to_f, precision: number_decimals).to_f
  end
end
