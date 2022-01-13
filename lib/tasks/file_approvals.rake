# frozen_string_literal: true

namespace :file_approvals do
  desc "Run file_approvals task"
  task create: :environment do
    DocumentTemplate.find_each do |document_template|
      if document_template.requires_approval?
        document_template.documents.each do |document|
          if document.file_versions.any? && document.file_approval.nil?
            document.file_approval = FileApproval.new(key: document.document_template.name)
            document.file_approval.created_at = document.latest_file_version.created_at
            document.save
          end
        end
      end
    end
  end
end
