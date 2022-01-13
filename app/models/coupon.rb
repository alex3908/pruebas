# frozen_string_literal: true

class Coupon < ApplicationRecord
  acts_as_paranoid
  enum status: { active: "active", deactive: "deactive" }

  has_many :payment_schemes

  belongs_to :promotion

  scope :usable, -> { where("usages < usage_limit OR usage_limit IS NULL") }

  def get_usages
    limit = self.usage_limit || "∞"
    "#{self.usages} / #{limit}"
  end
end
