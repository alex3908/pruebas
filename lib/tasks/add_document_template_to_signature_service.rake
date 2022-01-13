# frozen_string_literal: true

namespace :add_document_template_to_signature_service do
  desc "Backward compatibility with document templates"

  task run: :environment do
    p "Iniciando"
    document_template = DocumentTemplate.where("action = ?", DigitalSignature.document_types[:purchase_promise]).first
    if document_template.present?
      DigitalSignatureService.update_all(document_template_id: document_template.id)
      p "Servicios de firma digital actualizados con éxito"
    else
      p "No hay plantillas con un documento de firma configurado"
    end
  end
end
