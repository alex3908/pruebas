# frozen_string_literal: true

namespace :client_documents do
  desc "Migrate client attachments to documents"
  # This may be executed AFTER polymorphic_documents:run
  task create_default_templates: :environment do
    physical_client_documents.each do |key, value|
      DocumentTemplate.create(default_document_attr(key, value).merge(client_type: Client::PHYSICAL))
    end
    moral_client_documents.each do |key, value|
      DocumentTemplate.create(default_document_attr(key, value).merge(client_type: Client::MORAL))
    end
    general_client_documents.each do |key, value|
      DocumentTemplate.create(default_document_attr(key, value).merge(client_type: DocumentTemplate::GENERAL))
    end
  end

  def default_document_attr(key, value)
    {
      name: value,
      key: key,
      doc_type: DocumentTemplate::TYPE[:Client]
    }
  end

  def physical_client_documents
    {
      official_identification: "Identificación Oficial",
      curp: "CURP",
      address_proof: "Comprobante de Domicilio",
      birth_certificate: "Acta de Nacimiento"
    }
  end

  def moral_client_documents
    {
      constitutional_act: "Acta de Constitución"
    }
  end

  def general_client_documents
    {
      fiscal_act: "Acta Fiscal"
    }
  end


  task migrate_attachments: :environment do
    migrate_attachment(:official_identification)
    migrate_attachment(:curp)
    migrate_attachment(:address_proof)
    migrate_attachment(:birth_certificate)
    #migrate_attachment(:constitutional_act)
    migrate_attachment(:fiscal_act)
  end

  task migrate_attachments_constitutional_act: :environment do
    migrate_attachment(:constitutional_act)
  end

  def migrate_document(client, filename)
    client.documents
    .joins(:document_template)
    .find_by("document_templates.key = ?", filename)
    .tap do |document|
      next if document.nil?
      attachments = ActiveStorage::Attachment.where(record_type: "Client", record_id: client.id, name: filename)

      if attachments.any?
        file_version = document.file_versions.create
        FileApproval.where(approvable_type: "Client", approvable_id: client.id, key: filename)
                    .update_all(approvable_type: "Document", approvable_id: document.id)

        attachments.update_all(record_type: "FileVersion", record_id: file_version.id, name: "file")
      end
    end
  end

  def migrate_attachment(filename)
    ActiveStorage::Attachment.where(record_type: "Client", name: filename).each do |attachment|
      client = Client.find_by(id: attachment.record_id)
      document_template = DocumentTemplate.find_by(key: filename)

      if client.nil?
        puts '----------'
        puts attachment.record_id
        puts filename
        next
      end

      document = client.documents.find_by(document_template: document_template)

      if document.nil?
        puts '----------'
        puts client.id
        puts filename
        next
      end

      if document.file_versions.empty? || document.file_versions.first.file.attached?
        file_version = document.file_versions.create
      else
        file_version = document.file_versions.first
      end

      attachment.update(record_type: "FileVersion", record_id: file_version.id, name: "file")
    end
  end
end
