# frozen_string_literal: true

class CashFlowInvoice < DocumentHandler
  attr_reader :cash_flow, :for_email, :name, :with_signature

  FILE_PATH = "cash_flows/invoice.html.erb"
  NEW_FILE_PATH = "cash_flows/new_format/invoice.html.erb"

  def initialize(*args)
    @cash_flow = args.at(0)

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
        project: cash_flow.folder.project
      }
    end

    def assigns
      {
        with_signature: with_signature,
        name: name,
        cash_flow: cash_flow,
        email: for_email,
        branches: Branch.where(active: true),
        project_singular: cash_flow.folder.project.project_entity_name,
        phase_singular: cash_flow.folder.project.phase_entity_name,
        stage_singular: cash_flow.folder.project.stage_entity_name,
        lot_singular: cash_flow.folder.project.lot_entity_name,
      }
    end
end
