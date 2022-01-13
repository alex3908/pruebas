# frozen_string_literal: true

class ReferredClient < ApplicationRecord
  belongs_to :client, class_name: "Client", foreign_key: "client_id"
  belongs_to :referred_client, class_name: "Client", foreign_key: "referred_client_id"
  validates_uniqueness_of :client_id, scope: [:referred_client_id], message: "Ya se encuentra registrado"
  validate :validate_autoreference

  def validate_autoreference
    if client_id == referred_client_id
      errors.add(:base, "No puede referir este cliente así mismo")
      throw :abort
    end
  end
end
