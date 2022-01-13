# frozen_string_literal: true

class Enterprise < ApplicationRecord
  include Filterable

  has_many :online_payment_services
  has_many :digital_signature_services
  has_many :project, class_name: "Project", foreign_key: "enterprise_id"
  has_many :bank_accounts, -> { only_active }, as: :payable, dependent: :destroy

  def address_label
    "#{street}, Número #{outdoor_number}#{indoor_number.present? ? "Interior #{indoor_number}" : nil }, Colonia #{colony}, de la ciudad de #{location} de  #{state}, #{country} #{postal_code.present? ? "CP #{postal_code}" : nil }"
  end

  def available_netpay_service
    online_payment_services.netpay.available.first
  end
end
