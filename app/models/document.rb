# frozen_string_literal: true

class Document < ApplicationRecord
  scope :on_this_section, ->(section) { joins(:document_template).where("document_templates.document_section_id = (?)", section).order(:order) }
  scope :with_custom_action, ->(action) { joins(:document_template).where("document_templates.action = (?)", action).order(:order) }

  belongs_to :folder, required: false # TODO: This relation will be deleted after polymorphic document feature is released
  belongs_to :documentable, polymorphic: true
  belongs_to :document_template, optional: true

  has_one :file_approval, as: :approvable, dependent: :destroy
  has_many :file_versions, dependent: :destroy
  accepts_nested_attributes_for :file_versions

  def self.find_template(template)
    joins(:document_template).where("document_templates.key = (?)", template.to_s).take
  end

  def requires_approval?
    self.document_template.requires_approval?
  end

  def latest_file_version
    file_versions.newest.first
  end

  def blank?
    file_versions.empty?
  end

  def attached?
    !blank?
  end
end
