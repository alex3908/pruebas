# frozen_string_literal: true

module PaymentsHelper
  def encrypt_string(text)
    final_text = text.gsub (/(?<=.{2}).(?=.{1})/), "*"
    final_text
  end

  def pmt(rate, nper, pv, fv = 0, type = 0)
    ((-pv * pvif(rate, nper) - fv) / ((1.0 + rate * type) * fvifa(rate, nper)))
  end

  def fv(rate, nper, pmt, pv = 0, type = 0)
    if rate != 0
      temp = (1 + rate)**nper
      fact = (1 + rate * type) * (temp - 1) / rate
      -(pv * temp + pmt * fact)
    else
      -1 * (pv + pmt * nper)
    end
  end

  protected

    def pow1pm1(x, y)
      (x <= -1) ? ((1 + x)**y) - 1 : Math.exp(y * Math.log(1.0 + x)) - 1
    end

    def pow1p(x, y)
      (x.abs > 0.5) ? ((1 + x)**y) : Math.exp(y * Math.log(1.0 + x))
    end

    def pvif(rate, nper)
      pow1p(rate, nper)
    end

    def fvifa(rate, nper)
      (rate == 0) ? nper : pow1pm1(rate, nper) / rate
    end
end
