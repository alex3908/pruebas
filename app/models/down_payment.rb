# frozen_string_literal: true

class DownPayment < ApplicationRecord
  attr_accessor :copy

  belongs_to :credit_scheme

  before_destroy :can_be_deleted?, prepend: true

  validates_uniqueness_of :term, scope: :credit_scheme_id, unless: :min_is_changed?


  def upper_limit
    @limit = DownPayment.where.not(id: self.id).where("term > (?) AND credit_scheme_id = (?)", self.term, self.credit_scheme).order(term: :asc)
    if @limit.size > 0
      @limit.first.term - 1
    elsif self.credit_scheme.relative_down_payment
      "Variable"
    else
      self.credit_scheme.max_finance
    end
  end

  def min_is_changed?
    persisted? && min_changed?
  end

  def can_be_deleted?
    return if credit_scheme.down_payments.count > 1
    errors.add(:base, "No es posible eliminar todos los enganches mínimos.")
    throw :abort
  end
end
