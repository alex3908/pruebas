# frozen_string_literal: true

class StpService < StpBaseService
  FACTORS = [3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7].freeze
  FIRST_CLABE_DIGITS = "646180"

  def generate_clabe_for_client(folder_id)
    clabe = FIRST_CLABE_DIGITS + properties["key_code"] + folder_id.to_s.rjust(7, "0")

    clabe + generate_verificator_digit(clabe).to_s
  end

  def generate_verificator_digit(clabe)
    factor_and_modulo_array = factor_and_modulo(clabe)
    sum_result = sum_result_digits(factor_and_modulo_array)
    modulo_sum_and_modulo(sum_result)
  end

    private

      def factor_and_modulo(clabe)
        result = Array.new
        clabe = clabe.to_s
        index = 0

        while index < clabe.length
          result << (clabe[index].to_i * FACTORS[index]) % 10
          index = index + 1
        end

        result
      end

      def sum_result_digits(digits_array)
        digits_array.inject(0) do |sum, d|
          sum + d.to_i
        end
      end

      def modulo_sum_and_modulo(number)
        a = number % 10
        b = 10 - a

        b % 10
      end
end
