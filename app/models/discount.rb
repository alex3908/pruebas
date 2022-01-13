# frozen_string_literal: true

class Discount < ApplicationRecord
  include Filterable

  belongs_to :credit_scheme
  has_many :folder, class_name: "Folder", foreign_key: "discount_id"

  before_save :calculate_discount, if: :will_save_change_to_discount?
  before_destroy :can_be_deleted?, prepend: true

  validates_uniqueness_of :total_payments, scope: :credit_scheme_id, unless: :discount_is_changed?

  after_validation :set_name

  search_scope :stage_id, -> (id) {
    where(stage_id: id)
  }

  def calculate_discount
    discount = self.discount
    self.discount = discount / 100
  end

  def upper_limit
    @limit = Discount.where.not(id: self.id).where("total_payments > (?) AND is_active = (?) AND credit_scheme_id = (?)", self.total_payments, true, self.credit_scheme).order(total_payments: :asc)
    @limit.size > 0 ? @limit.first.total_payments - 1 : self.credit_scheme.periods.inject(0) { |sum, period| sum + period.payments }
  end

  def set_name
    self.name = total_payments == 1 ? "Contado" : "#{total_payments} meses"
  end

  def discount_is_changed?
    persisted? && discount_changed?
  end

  def can_be_deleted?
    return if credit_scheme.discounts.count > 1
    errors.add(:base, "No es posible eliminar todos los descuentos base.")
    throw :abort
  end
end
