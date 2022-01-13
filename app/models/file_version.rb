# frozen_string_literal: true

class FileVersion < ApplicationRecord
  belongs_to :document

  has_one_attached :file

  scope :newest, -> { order(created_at: :desc) }

  after_save :create_file_approval, if: :requires_approval?
  after_save :automated_move

  def requires_approval?
    document.requires_approval?
  end

  def create_file_approval
    if document.file_approval.present?
      document.file_approval.update!(approved_at: nil, approved_by_id: nil, status: 0)
    else
      document.file_approval = FileApproval.new(key: document.document_template.name)
    end
  end

  private

    def automated_move
      folder = document.documentable
      if document.file_versions.size == 1 && document.documentable_type == "Folder" && folder.step.document_templates.any?
        document_templates_ids = folder.step.document_templates.pluck(:id)
        automated_documents = folder.documents.where(document_template_id: document_templates_ids)
        empty_document = automated_documents.any? { |document| document.file_versions.empty? }
        folder.approve unless empty_document
      end
    end
end
