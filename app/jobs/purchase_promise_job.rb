# frozen_string_literal: true

class PurchasePromiseJob < ApplicationJob
  queue_as :high_priority

  def perform(folder_id, status = nil, is_signature = false)
    purchase_promise_pdf = nil
    status ||= NullJobStatus.new(folder_id)
    status.add_progress!("Generando documento...")
    folder = Folder.includes([lot: [stage: [phase: :project]]]).find_by(id: folder_id)

    lot = folder.lot
    stage = folder.stage
    contract = folder.ruled_contract
    base64PdfArray = []
    begin
      report = Tempfile.new([ status.file_name, ".pdf" ])
      status.add_progress!("Generando promesa de compra venta...")

      if status.file.nil?
        base64PdfArray << folder.purchase_promise_document.to_pdf_base_64
      else
        if contract.present? && contract.fit_signature?
          base64PdfArray << Base64.strict_encode64(PdfService.instance.set_fit_signature(folder.purchase_promise_document.to_pdf_base_64))
        else
          base64PdfArray << folder.purchase_promise_document.to_pdf_base_64
        end
      end

      contract.contract_annexes.order(:order).each do |contract_annexe|
        if validate_annexe_key(:PHASE, contract_annexe.annexe_id)
          status.add_progress!("Generando anexo de Fase...")
          contract_annexe.amount.times do |count|
            base64PdfArray << Annexe_1.new(lot.stage).to_pdf_base_64
          end
        elsif validate_annexe_key(:STAGE, contract_annexe.annexe_id)
          status.add_progress!("Generando anexo de Etapa...")
          contract_annexe.amount.times do |count|
            base64PdfArray << Annexe_2.new(lot).to_pdf_base_64
          end
        elsif validate_annexe_key(:LOT, contract_annexe.annexe_id)
          status.add_progress!("Generando anexo de Lote...")
          contract_annexe.amount.times do |count|
            base64PdfArray << Annexe_3.new(lot).to_pdf_base_64
          end
        elsif validate_annexe_key(:PLD, contract_annexe.annexe_id)
          status.add_progress!("Generando anexo PLD...")
          contract_annexe.amount.times do |count|
            base64PdfArray << folder.annexe_pld_document.to_pdf_base_64
          end
        elsif validate_annexe_key(:LOT_ANNEXES, contract_annexe.annexe_id)
          if lot.pdf_annexes.any?(&:present?)
            status.add_progress!("Generando anexos de #{stage.phase.project.lot_entity_name} para PDF...")
            contract_annexe.amount.times do |count|
              lot.pdf_annexes.each do |attachment|
                base64PdfArray << Base64.strict_encode64(attachment.download)
              end
            end
          end
        elsif validate_annexe_key(:STAGE_ANNEXES, contract_annexe.annexe_id)
          if stage.pdf_annexes.any?(&:present?)
            status.add_progress!("Generando anexos de etapa para PDF...")
            contract_annexe.amount.times do |count|
              stage.pdf_annexes.each do |attachment|
                base64PdfArray << Base64.strict_encode64(attachment.download)
              end
            end
          end
        elsif validate_annexe_key(:AMORTIZATION_TABLE, contract_annexe.annexe_id)
          status.add_progress!("Generando tabla de amortización...")
          contract_annexe.amount.times do |count|
            base64PdfArray << folder.amortization_table_document(true, is_signature).to_pdf_base_64
          end
        elsif validate_annexe_key(:PURCHASE_CONDITIONS, contract_annexe.annexe_id)
          status.add_progress!("Generando condiciones de compra...")
          contract_annexe.amount.times do |count|
            base64PdfArray << folder.purchase_conditions_document(false, true).to_pdf_base_64
          end
        elsif validate_annexe_key(:ADDITIONAL_ANNEXES, contract_annexe.annexe_id)
          if contract.present? && contract.annexes.attached?
            status.add_progress!("Generando anexos adicionales de contrato...")
            contract_annexe.amount.times do |count|
              contract.annexes.each do |attachment|
                base64PdfArray << Base64.strict_encode64(attachment.download)
              end
            end
          end
        elsif validate_annexe_key(:FOLDER, contract_annexe.annexe_id)
          if contract.present?
            status.add_progress!("Generando anexos del expediente...")
            contract_annexe.amount.times do |count|
              contract.document_templates.for_folders.order(order: :asc).each do |document_template|
                document = folder.documents.find_by_document_template_id(document_template.id)
                if document.present? && document.latest_file_version.present?
                  base64PdfArray << Base64.strict_encode64(document.latest_file_version.file.download)
                end
              end
            end
          end
        elsif validate_annexe_key(:CLIENT, contract_annexe.annexe_id)
          if contract.present?
            status.add_progress!("Generando anexos de clientes...")
            folder.clients.each do |client|
              contract_annexe.amount.times do |count|
                contract.document_templates.for_clients.order(order: :asc).each do |document_template|
                  document = client.documents.find_by_document_template_id(document_template.id)
                  if document.present? && document.latest_file_version.present?
                    base64PdfArray << Base64.strict_encode64(document.latest_file_version.file.download)
                  end
                end
              end
            end
          end
        end
      end

      merged_pdf = PdfService.instance.get_merged_pdf(base64PdfArray)

      File.open(report.path, "wb") do |file|
        file.write(merged_pdf)
      end

      file_merged_for_coordinates = File.open(report.path, "rb")
      pages = PDFTextProcessor.process(file_merged_for_coordinates)

      if status.file.nil?
        purchase_promise_pdf = { file: merged_pdf, file_name: status.file_name, pages: pages }
      else
        file_merged_for_download = File.open(report.path, "rb")
        status.file.attach(io: file_merged_for_download, filename: "#{status.file_name}.pdf")
        status.add_progress!("Limpiando proceso...")
      end

    ensure
      report.close
      report.unlink
      status.mark_completed!
      purchase_promise_pdf
    end
  rescue StandardError => e
    status.mark_failed!(e.to_s)
    status.log_error!(e)
    raise e
  end

  def validate_annexe_key(key, annexe_id)
    ContractAnnexe::ANNEXES_NAMES[key] == ContractAnnexe::ANNEXES_NAMES.to_a[annexe_id].second
  end
end
