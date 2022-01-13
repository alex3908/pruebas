# frozen_string_literal: true

class DigitalSignatureLog < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :digital_signature

  def status_label
    "#{I18n.t("digital_signatures.statuses.#{status}")}"
  end
end
