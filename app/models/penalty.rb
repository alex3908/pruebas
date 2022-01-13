# frozen_string_literal: true

class Penalty < ApplicationRecord
  belongs_to :installment
  belongs_to :user
  belongs_to :canceled_by, class_name: "User", foreign_key: "canceled_by", optional: true
end
