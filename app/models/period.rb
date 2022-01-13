# frozen_string_literal: true

class Period < ApplicationRecord
  belongs_to :credit_scheme

  before_destroy :can_be_deleted?, prepend: true
  before_update :prevent_update

  validate :is_changed?

  def can_be_deleted?
    return if credit_scheme.periods.count > 1
    errors.add(:base, "No es posible eliminar todos los periodos.")
    throw :abort
  end

  def is_changed?
    if persisted? && changed?
      errors.add(:base, "No es posible editar un periodo ya existente.")
    end
  end
end
