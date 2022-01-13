# frozen_string_literal: true

class PaymentInvoice < DocumentHandler
  attr_reader :payment, :for_email, :name, :with_signature

  FILE_PATH = "payments/invoice.html.erb"
  NEW_FILE_PATH = "payments/new_format/invoice.html.erb"

  def initialize(*args)
    @payment = args.at(0)

    opts = if args.last.class == Hash
      args.last
    else
      {}
    end
    @for_email = opts[:for_email]
    @name = opts[:name]
    @with_signature = opts[:with_signature]
    opts[:layout] = "pdf"

    format = true ? NEW_FILE_PATH : FILE_PATH
    super(format, opts)
  end

  private

    def locals
      {
        project: payment.installment.folder.project
      }
    end

    def assigns
      {
        with_signature: with_signature,
        name: name,
        payment: payment,
        email: for_email,
        branches: Branch.where(active: true),
        project_singular: payment.installment.folder.project.project_entity_name,
        phase_singular: payment.installment.folder.project.phase_entity_name,
        stage_singular: payment.installment.folder.project.stage_entity_name,
        lot_singular: payment.installment.folder.project.lot_entity_name,
      }
    end
end
