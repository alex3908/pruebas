# frozen_string_literal: true

namespace :documents do
  desc "Migrate folder attachments to new documents"

  task create_default_templates: :environment do
    attachment_filenames.each do |key, value|
      DocumentTemplate.create(
        name: value,
        document_section: DocumentSection.find_or_create_by(name: attachment_section[key]),
        key: key
      )
    end
  end

  task migrate_folder_attachments: :environment do
    Folder.find_each do |folder|
      create_document(folder, :bank_deposit)
      create_document(folder, :bank_deposit_complement)
      create_document(folder, :reserve_receipt)
      create_document(folder, :down_payment_voucher)
      create_document(folder, :down_payment_receipt)
      create_document(folder, :federal_cedula)
      create_document(folder, :conditions_purchase)
      create_document(folder, :marriage_act)
      create_document(folder, :agree_letter)
      create_document(folder, :amortization_table)
      create_document(folder, :amortization_cover)
      create_document(folder, :purchase_promise)
      create_document(folder, :promissory_note)
      create_document(folder, :commission_voucher)
      create_document(folder, :commission_receipt)
    end
  end

  def create_document(folder, filename)
    folder.documents
          .joins(:document_template)
          .find_by("document_templates.key = (?)", filename)
          .tap do |document|

      attachments = ActiveStorage::Attachment.where(record_type: "Folder", record_id: folder.id, name: filename)
  
      if attachments.any?
        file_version = document.file_versions.create
        FileApproval.where(approvable_type: "Folder", approvable_id: folder.id, key: filename)
                    .update_all(approvable_type: "Document", approvable_id: document.id)

        
        attachments.update_all(record_type: "FileVersion", record_id: file_version.id, name: "file")
      end
    end
  end

  def attachment_filenames
    {
      bank_deposit: "COMPROBANTE DEL PAGO (APARTADO)",
      bank_deposit_complement: "COMPROBANTE DEL PAGO (COMPLEMENTO APARTADO)",
      reserve_receipt: "RECIBO DE APARTADO",
      down_payment_voucher: "COMPROBANTE DEL PAGO (ENGANCHE)",
      down_payment_receipt: "RECIBO DE ENGANCHE",
      conditions_purchase: "CONDICIONES DE COMPRA",
      amortization_table: "AMORTIZACION (CARÁTULA)",
      federal_cedula: "CEDULA FISCAL (opcional)",
      agree_letter: "CARTA DE CONFORMIDAD (opcional)",
      marriage_act: "ACTA DE MATRIMONIO (opcional)",
      purchase_promise: "PROMESA DE COMPRAVENTA",
      promissory_note: "PAGARÉ",
      commission_voucher: "VOUCHER DE COMISIÓN",
      commission_receipt: "RECIBO DE COMISIÓN"
    }
  end

  def attachment_section
    {
      bank_deposit: "Reservación",
      bank_deposit_complement: "Reservación",
      reserve_receipt: "Reservación",
      down_payment_voucher: "Enganche",
      down_payment_receipt: "Enganche",
      conditions_purchase: "Documentos del Expediente",
      amortization_table: "Documentos del Expediente",
      federal_cedula: "Documentos del Expediente",
      agree_letter: "Documentos del Expediente",
      marriage_act: "Documentos del Expediente",
      purchase_promise: "Documentos del Expediente",
      promissory_note: "Documentos del Expediente",
      commission_voucher: "Cuota por apertura",
      commission_receipt: "Cuota por apertura"
    }
  end
end
