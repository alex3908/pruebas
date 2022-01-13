# frozen_string_literal: true

class DocumentTemplate < ApplicationRecord
  include RailsSortable::Model
  set_sortable :order
  GENERAL = "general"

  scope :for_folders, ->() { where(doc_type: TYPE[:Folder]) }

  scope :for_clients, ->() { where(doc_type: TYPE[:Client]) }
  scope :for_general_clients, ->() { where(doc_type: TYPE[:Client], client_type: GENERAL) }
  scope :for_physical_clients, ->() { where(doc_type: TYPE[:Client], client_type: Client::PHYSICAL) }
  scope :for_moral_clients, ->() { where(doc_type: TYPE[:Client], client_type: Client::MORAL) }

  enum section: [
    :other,
    :downpayment,
    :reservation
  ]

  enum permissions: [
    :default,
    :promise,
    :promissory_note
  ]

  enum action: [
    :initial_payment,
    :initial_payment_compliment,
    :down_payment,
    :commission_voucher,
    :commission_receipt,
    :purchase_promise
  ]

  belongs_to :document_section, required: false

  has_many :step_role_document_template, dependent: :destroy
  has_many :step_documents, dependent: :destroy
  has_many :documents
  has_many :contract_document_templates, dependent: :destroy
  has_many :contracts, through: :contract_document_templates
  has_many :digital_signature_services
  has_many :document_noms, class_name: "DigitalSignatureService", foreign_key: "document_nom_id"
  accepts_nested_attributes_for :step_documents

  TYPE = { "Folder": "folder", "Client": "client" }
  enum doc_type: { folder: "folder", client: "client" }
  enum client_type: { general: GENERAL, physical: Client::PHYSICAL, moral: Client::MORAL }

  before_create :assign_key
  after_create :perform_job

  FILE_TYPES = [{ file_type: ".jpg", label: "JPG" }, { file_type: ".png", label: "PNG" }, { file_type: "application/pdf", label: "PDF" }]

  scope :visible, -> { where(visible: true) }

  def get_formats
    self.formats.delete_if(&:empty?).join(",").to_s
  end

  def get_doc_type
    return "Expediente" if self.folder?
    "Cliente"
  end

  def get_client_type
    return "Físico" if self.client_type == Client::PHYSICAL
    return "Moral" if self.client_type == Client::MORAL
    GENERAL.capitalize
  end

  private
    def perform_job
      DocumentTemplateCreationJob.perform_later(self)
    end

    def assign_key
      self.key = (self.key.nil? ? name.parameterize : key.parameterize) + "-" + SecureRandom.hex(5).upcase
    end
end
