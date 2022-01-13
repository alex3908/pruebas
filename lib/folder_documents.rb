# frozen_string_literal: true

class FolderDocuments < DocumentHandler
  attr_reader :folder, :lot, :phase, :stage, :project, :quotation, :controller

  include FoldersHelper

  def initialize(folder, lot, phase, stage, project, quotation)
    @folder ||= folder
    @lot ||= lot
    @phase ||= phase
    @stage ||= stage
    @project ||= project
    @quotation ||= quotation
    @controller ||= ApplicationController.new
  end

  def render_document
    PdfService.instance.get_merged_pdf([purchase_conditions_document, amortization_cover_document, down_payment_receipt_document, opening_commission_document, documents_signatures_template])
  end

    protected


      def purchase_conditions_document
        PurchaseConditions.new(folder, false, false).to_pdf_base_64
      end

      def amortization_cover_document
        AmortizationCover.new(folder, false, quotation, controller).to_pdf_base_64
      end

      def down_payment_receipt_document
        DownPaymentReceipt.new(folder, lot, phase, stage, project, "down_payment", controller).to_pdf_base_64
      end

      def opening_commission_document
        DownPaymentReceipt.new(folder, lot, phase, stage, project, "opening_commission", controller).to_pdf_base_64
      end

      def documents_signatures_template
        DocumentsSignatures.new(folder, controller).to_pdf_base_64
      end
end
