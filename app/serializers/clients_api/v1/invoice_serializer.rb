# frozen_string_literal: true

class ClientsApi::V1::InvoiceSerializer < ClientsApi::V1::BaseSerializer
  attributes :cash_flow, :invoice

  def cash_flow
    object.id
  end

  def invoice
    invoice_folder_cash_flow_url(object.folder, object, type: "voucher", download: true, format: :pdf)
  end
end
