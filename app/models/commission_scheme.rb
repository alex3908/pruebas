# frozen_string_literal: true

class CommissionScheme < ApplicationRecord
  has_many :stages
  has_many :commission_schemes_roles, dependent: :destroy

  accepts_nested_attributes_for :commission_schemes_roles, reject_if: :all_blank, allow_destroy: true

  validates :name, :global_commission, presence: true
  validates :global_commission, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :duplicate_commission_for_roles, on: [:create, :update]

  before_destroy :commission_scheme_in_use, prepend: true

  def duplicate_commission_for_roles
    if commission_schemes_roles.detect { |e| commission_schemes_roles.count { |c| c.role_id == e.role_id && c.folder_user_concept_id == e.folder_user_concept_id } > 1 }
      self.errors.add(:commission_schemes_roles, :duplicate_commission_roles)
    end
  end

  def commission_scheme_in_use
    if stages.any?
      self.errors.add(:commission_schemes_roles, :in_use)
      throw :abort
    end
  end
end
