
# frozen_string_literal: true

class StepRole < ApplicationRecord
  after_create :create_step_role_document

  belongs_to :step
  belongs_to :role, with_deleted: true
  has_many :step_role_document_templates, dependent: :destroy
  has_many :documents, through: :step_role_document_templates
  has_many :downloadable_files, dependent: :destroy

  accepts_nested_attributes_for :step_role_document_templates, allow_destroy: true
  accepts_nested_attributes_for :downloadable_files, allow_destroy: true

  def readable_file?(file_key)
    self.step_role_document_templates.joins(:document_template).where("document_templates.key = (?)", file_key).take.readable
  end

  def uploadable_file?(file_key)
    self.step_role_document_templates.joins(:document_template).where("document_templates.key = (?)", file_key).take.uploadable
  end

  def editable_file?(file_key)
    self.step_role_document_templates.joins(:document_template).where("document_templates.key = (?)", file_key).take.editable
  end

  def destroyable_file?(file_key)
    self.step_role_document_templates.joins(:document_template).where("document_templates.key = (?)", file_key).take.destroyable
  end

  def has_any_document_permission?
    self.step_role_document_templates.where("readable = (?) OR uploadable = (?) OR editable = (?) OR destroyable = (?)", true, true, true, true).any?
  end

  def create_step_role_document
    DocumentTemplate.find_each do |document_template|
      StepRoleDocumentTemplate.create(step_role: self, document_template: document_template)
    end
  end
end
