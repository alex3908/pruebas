# frozen_string_literal: true

class AnnexePld < DocumentHandler
  include QuotationsHelper, ContractsHelper, ActionView::Helpers::NumberHelper, ActionView::Helpers::TagHelper

  FILE_PATH = "folders/files/purchase_promise_attached.html.erb"
  NEW_FILE_PATH = "folders/files/new_format/purchase_promise_attached.html.erb"
  SINGLEPAGE_FILE_PATH = "folders/files/singlepage_format/purchase_promise_attached.html.erb"

  def initialize(clients, project)
    # Todo: Read setting to define the format
    @clients = clients
    @project = project
    single_page = Setting.find_by_key("single_page_pld").try(:convert)
    if single_page
      format = SINGLEPAGE_FILE_PATH
    else
      format = true ? NEW_FILE_PATH : FILE_PATH
    end
    super(format, layout: "pdf")
  end

  protected

    def locals
      { clients: @clients, project: @project }
    end
end
