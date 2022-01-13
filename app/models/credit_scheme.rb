# frozen_string_literal: true

class CreditScheme < ApplicationRecord
  include PurchaseConditionsConcern

  attr_accessor :copy
  acts_as_paranoid

  enum quotation_type: { multiple_periods: "multiple_periods", one_period: "one_period", simple_interest: "simple_interest" }
  enum min_last_payment_payment_way: { percentage: "percentage", amount: "amount" }

  has_many :stages
  has_many :periods, dependent: :destroy
  has_many :discounts, dependent: :destroy
  has_many :payment_schemes
  has_many :folders, through: :payment_schemes
  has_many :down_payments

  belongs_to :document_template, required: false
  belongs_to :payment_method, required: false

  has_paper_trail skip: [:updated_at], on: [:update]

  accepts_nested_attributes_for :periods, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :discounts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :down_payments, reject_if: :all_blank, allow_destroy: true

  def immediate_construction_enabled?
    immediate_extra_months > 0
  end

  def immediate_lots_limit_reached?
    sold_immediate_folders_percent >= max_percent_immediate_lots_sold
  end

  def sold_immediate_folders_percent
    (folders.sold_immediate_construction.count.to_f / lots.count.to_f) * 100
  end

  def get_min_down_payment(num)
    down_payment = self.down_payments.where("term <= (?)", 1).order(term: :desc).first
    down_payment.min * num
  end

  def is_copy?
    self.copy
  end

  def can_edit_attribute?
    new_record? || (persisted? && folders.size.zero?)
  end

  def last_payment_label
    percentage? ? "Porcentaje de mínimo" : "Monto mínimo"
  end

  def purchase_conditions_formatted(opening_commission = 0, purchase_conditions, start_date, release_date)
    super(
      opening_commission: opening_commission,
      purchase_conditions: purchase_conditions,
      phase_date: start_date,
      stage_date: release_date,
    )
  end
end
