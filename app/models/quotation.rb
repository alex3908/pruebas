# frozen_string_literal: true

class Quotation
  attr_writer :amr, :down_payment_monthly_payments
  attr_accessor :plan_name, # Nombre del plan
    :total_payments, # Total de pagos
    :down_payment_finance, # Meses a financiar el enganche
    :amount_to_finance, # Monto a financiar (Total - enganche)
    :price, # Precio por m2 sin descuento
    :total_price, # Precio total de venta con descuento
    :initial_payment, # Apartado
    :down_payment, # Enganche total
    :payments, # Total de pagos
    :discount, # Descuento total aplicado
    :saving, # Ahorro de precio de lista
    :total_minus_down_payment, # Monto total sin enganche y con descuento
    :down_payment_to_differ, # Enganche a diferir
    :total, # Precio sin descuento
    :total_with_discount, # Precio total de venta con descuento
    :total_discount, # Descuento total aplicado
    :down_payment_total, # Amortizaciones contempladas
    :interest_payments, # Amortizaciones contempladas
    :reserve, # Unknown
    :down_payment_percentage, # Porcentaje de enganche
    :updates, # Actualizaciones por periodos con total de pagos y tasa de interes
    :is_down_payment_differ, # El enganche se encuentra financiado
    :down_payment_monthly_payment, # Monto a pagar por pago a enganche
    :down_payment_first_pay_date, # Fecha de primer pago de enganche
    :price_with_interest, # Precio total de la unidad contando los intereses
    :have_capital_payment, # Unknown
    :initial_periods, # Actualizaciones por periodos con total de pagos y tasa de interes
    :complement_payment, # Complemento de pago pendiente a el pago definido en el anticipo.
    :interest_free_period, # Meses sin intereses
    :down_payments, # Pagos de enganche y apartado contemplados
    :last_payment, # Cantidad de contra entrega
    :last_payment_percentage # Porcentaje de contra entrega

  def initialize(h)
    h.each { |k, v| public_send("#{k}=", v) }
  end

  def initial_payment
    @initial_payment = @initial_payment.to_i
  end

  def first_payment_down_payment
    down_payment_monthly_payments.find do |el|
      el[:concept] == Installment::CONCEPT[:DOWN_PAYMENT] && el[:number].to_i == 1
    end
  end

  def down_payment_monthly_payments
    @down_payment_monthly_payments.map do |el|
      normalize_date(el)
    end
  end

  def amr
    @amr.map do |el|
      normalize_date(el)
    end
  end

  def down_payments
    @down_payments.map do |el|
      hash = HashWithIndifferentAccess.new(el)
      hash[:total_payments] = hash[:total_payments].to_i
      hash
    end
  end

  def interest_payments
    @interest_payments.map do |el|
      HashWithIndifferentAccess.new(el)
    end
  end
  private

    def normalize_date(el)
      hash = HashWithIndifferentAccess.new(el)
      hash[:date] = Date.parse(hash[:date].to_s)
      hash
    end
end
