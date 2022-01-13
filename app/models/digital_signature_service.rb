# frozen_string_literal: true

class DigitalSignatureService < ApplicationRecord
  acts_as_paranoid
  enum name: HashWithIndifferentAccess.new(trato: "Trato")
  validate :validate_nom_field
  belongs_to :enterprise
  belongs_to :step, optional: true
  belongs_to :document_template, optional: true
  belongs_to :document_nom, class_name: "DocumentTemplate", optional: true
  has_many :digital_signatures


  def creator
    if name == "trato"
      TratoService.new(properties, environment)
    end
  end

  def image
    if name == "trato"
      "trato.svg"
    end
  end

  private

    def validate_nom_field
      if document_template_id.present? && document_nom_id.present? && document_template_id == document_nom_id
        errors.add(:document_template_id, "Adjuntar contrato debe ser diferente a Adjuntar NOM-151")
      end
    end
end
