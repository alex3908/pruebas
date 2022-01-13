# frozen_string_literal: true

namespace :contract_client_documents do
  desc "Migrate contract-client document relation"
  task migrate: :environment do
    ContractClientDocument.all.each do |contract_client_document|
      doc_name = ContractClientDocument::DOCUMENTS.keys[contract_client_document.client_document_id].to_s
      document_template = DocumentTemplate.where("UPPER(document_templates.name) LIKE UPPER('#{doc_name}')").take
      ContractDocumentTemplate.create(
        contract_id: contract_client_document.contract_id,
        document_template: document_template
      ) if doc_name.present? && document_template.present?
    end
  end
end
