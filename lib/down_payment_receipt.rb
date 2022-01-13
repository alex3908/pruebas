# frozen_string_literal: true

class DownPaymentReceipt < DocumentHandler
  FILE_PATH = "folders/files/down_payment_receipt.html.erb"
  NEW_FILE_PATH = "folders/files/new_format/down_payment_receipt.html.erb"

  attr_reader :folder, :lot, :phase, :stage, :project, :key, :with_copy, :with_signature
  def initialize(folder, lot, phase, stage, project, key, controller)
    @folder ||= folder
    @lot ||= lot
    @phase ||= phase
    @stage ||= stage
    @project ||= project
    @key ||= key
    @with_copy = false
    @with_signature = false

    format = true ? NEW_FILE_PATH : FILE_PATH
    super(format, layout: "pdf", controller: controller)
  end

    protected

      def assigns
        {
            key: key,
            folder: folder,
            lot: lot,
            phase: phase,
            stage: stage,
            project: project,
            with_copy: with_copy,
            with_signature: with_signature
        }.merge(set_receipt_type(key))
      end
      def locals
        {}
      end

      def set_receipt_type(type)
        if type == "opening_commission"
          amount = folder.payment_scheme.opening_commission
          title = "CUOTA POR APERTURA"
          concept = "Cuota de apertura"
        else
          amount = folder.payment_scheme.down_payment / folder.payment_scheme.down_payment_finance
          title = "RECIBO DE ENGANCHE"
          concept = "Enganche"
        end
        { amount: amount, title: title, concept: concept }
      end
end
