# frozen_string_literal: true

class PaymentScheme < ApplicationRecord
  # TODO: Move logic of the controllers concern to a model concern
  include Filterable, InstallmentConcern, PromotionHandler
  validates :name, presence: true
  validates :buy_price, presence: true, numericality: true
  validates :down_payment_finance, presence: true, numericality: { only_integer: true }
  validates :total_payments, presence: true, numericality: { only_integer: true }
  validates :discount, allow_blank: true, numericality: true
  belongs_to :folder
  belongs_to :credit_scheme
  belongs_to :promotion, optional: true, with_deleted: true
  belongs_to :coupon, optional: true, with_deleted: true
  after_update :binnacle, :update_installments
  after_touch :update_installments

  before_validation :can_sell_lot_as_immediate

  enum promotion_operation: { over: 0, higher: 1, addition: 2 }
  # TODO: Replace with I18n method
  def operation_label
    if self.over?
      "Multiplicativo"
    elsif self.higher?
      "Mayor"
    elsif self.addition?
      "Suma"
    else
      "Sin asignar"
    end
  end

  def complement_payment
    if self.initial_payment <= self.lock_payment
      0
    else
      self.initial_payment - self.lock_payment
    end
  end

  def binnacle
    unless Current.user.nil?
      filtered_changes = previous_changes
      previous_changes.keys.each do |attr_name, attr_value|
        if previous_changes[attr_name][0].nil?
          filtered_changes[attr_name][0] = ""
        end

        if previous_changes[attr_name][1].nil?
          filtered_changes[attr_name][1] = ""
        end
      end

      if filtered_changes[:delivery_date].present?
        filtered_changes[:delivery_date][0] = filtered_changes[:delivery_date][0].strftime("%m-%d-%Y") unless filtered_changes[:delivery_date][0].blank?
        filtered_changes[:delivery_date][1] = filtered_changes[:delivery_date][1].strftime("%m-%d-%Y") unless filtered_changes[:delivery_date][1].blank?
      end

      element_changes = "#{filtered_changes.except(:updated_at)}".gsub("=>", ":")

      if element_changes != "{}"
        @log = {
          date: Time.zone.now,
          element_changes: element_changes,
          element: "scheme",
          element_id: self.id,
          user_id: Current.user.id
        }

        Log.create(@log)
      end
    end
  end

  def total_calculation
    promotion_calculator(self.buy_price * self.folder.lot.area, self.discount, self.promotion_discount, self.promotion_operation, self.promotion&.amount || 0, self.promotion&.operation || nil, self.coupon&.promotion&.amount || 0, self.coupon&.promotion&.operation || nil)
  end

  def total_discount
    total_calculation.discount
  end

  def payment_confirmed_for?(concept)
    if concept == :initial_payment || concept == :initial_payment_complement
      folder.payment_scheme.online_payment_id.present?
    elsif concept == :down_payment
      folder.payment_scheme.down_payment_paid
    end
  end

  def has_invalid_coupon?
    coupon = folder.payment_scheme.coupon
    invalid_coupon = coupon.present? && coupon.usage_limit.present? && coupon.usages >= coupon.usage_limit
    invalid_coupon
  end

  def update_installments
    reload_installments(folder)
  end

  private

    def can_sell_lot_as_immediate
      return if immediate_extra_months.zero?

      stage = folder.stage
      percent = credit_scheme.sold_immediate_folders_percent
      if percent > stage.credit_scheme.max_percent_immediate_lots_sold
        errors.add(:lot, "No se pueden vender más #{stage.phase.project.lot_entity_plural} de construcción inmediata en ésta etapa")
      end
    end
end
