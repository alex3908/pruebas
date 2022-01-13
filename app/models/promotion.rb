# frozen_string_literal: true

class Promotion < ApplicationRecord
  acts_as_paranoid

  enum operation: { over: 0, higher: 1, addition: 2 }
  enum discount_type: { amount: 0, percentage: 1, both: 2 }, _prefix: true
  enum downpayment_type: { amount: 0, percentage: 1 }, _prefix: true
  enum initialpayment_type: { amount: 0, percentage: 1 }, _prefix: true

  has_many :stage_promotions, dependent: :destroy
  has_many :stages, through: :stage_promotions
  has_many :coupons
  has_many :payment_schemes

  before_save :calculate_amount, if: :will_save_change_to_amount?

  scope :in_dates, -> (_today) { where("(start_date <= :today AND end_date >= :today) OR (start_date <= :today AND end_date IS NULL)", today: _today) }
  scope :with_size, -> (_size) { where("(min_area <= :size AND max_area >= :size) OR (min_area <= :size AND max_area IS NULL)", size: _size) }
  scope :active, -> () { where(active: true) }

  has_paper_trail skip: [:updated_at], on: [:update]

  def self.search(params)
    promotions = Promotion.all
    promotions = promotions.where("LOWER(name) LIKE LOWER(?)", "%#{params[:search_name]}%".delete(" \t\r\n")) if params[:search_name].present?
    promotions
  end

  def operation_label
    if self.over?
      "Multiplicativo"
    elsif self.higher?
      "Mayor"
    elsif self.addition?
      "Suma"
    end
  end

  def calculate_amount
    amount = self.amount
    self.amount = amount / 100
  end

  def valid(area:, terms:, downpayment_terms:)
    infinity = Float::INFINITY
    area.between?(min_area, max_area || infinity) && terms.between?(term_min, term_max || infinity) && downpayment_terms.between?(downpayment_min, downpayment_max || infinity)
  end

  def description
    message = []

    if (min_area != 0) && max_area.nil?
      message.push("para unidades con un área mayor a #{"%.2f" % min_area}m²")
    elsif (min_area != 0) && max_area.present?
      message.push("para unidades con un área entre #{"%.2f" % min_area}m² y #{"%.2f" % max_area}m²")
    end

    if (term_min != 0) && term_max.nil?
      message.push("seleccionando un plazo mínimo de #{term_min} #{'mes'.pluralize(:es)}")
    elsif (term_min != 0) && term_max.present?
      if term_min == term_max
        message.push("seleccionando un plazo de #{term_min} #{'mes'.pluralize(:es)}")
      else
        message.push("seleccionando un plazo entre #{term_min} #{'mes'.pluralize(term_min, :es)} y #{term_max} #{'mes'.pluralize(term_max, :es)}")
      end
    end

    if (downpayment_min != 0) && downpayment_max.nil?
      message.push("seleccionando un enganche diferido mínimo de #{downpayment_min} #{'mes'.pluralize(downpayment_min, :es)}")
    elsif (downpayment_min != 0) && downpayment_max.present?
      message.push("seleccionando un enganche diferido entre #{downpayment_min} #{'mes'.pluralize(downpayment_min, :es)} y #{downpayment_max} #{'mes'.pluralize(downpayment_max, :es)}")
    end

    if message.length == 1
      "Esta promoción aplica #{message.first}"
    elsif message.length == 2
      "Esta promoción aplica #{message.first} y #{message.second}"
    elsif message.length == 3
      "Esta promoción aplica #{message.first}, #{message.second} y #{message.third}"
    end
  end
end
