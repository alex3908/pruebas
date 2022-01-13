# frozen_string_literal: true

class EmailTemplate < ApplicationRecord
  has_many :automated_emails, dependent: :destroy
  validate :validate_liquid_format

  has_many_attached :attachments

  def template
    Liquid::Template.parse(html)
  end

  def validate_liquid_format
    Liquid::Template.parse(html)
  rescue Liquid::SyntaxError
    errors.add(:html, "El formato de la plantilla es incorrecto, revisa tus variables.")
  end

  def render_preview
    EmailTemplatePreview.new(self)
  end
end
