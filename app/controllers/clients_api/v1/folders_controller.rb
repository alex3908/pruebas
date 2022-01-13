# frozen_string_literal: true

class ClientsApi::V1::FoldersController < ClientsAPI::V1::BaseController
  before_action :set_folder, except: [:index]
  before_action :set_cash_flow, only: [:invoice]

  def index
    folders = current_user.client.folders.active
    render json: folders
  end

  def stp
    render json: custom_json({ clabe: @folder.stp_clabe })
  end

  def documents
    render json: @folder.document_by_template_id(params[:document_template_id])
  end

  def account_status
    @pdf = @folder.account_status.to_pdf
    send_data @pdf, filename: "Estado de Cuenta", type: "application/pdf", disposition: "inline"
  end

  def pending_payments
    pending_payments = @folder.pending_payments
    render json: pending_payments
  end

  def cash_flows
    render json: @folder.cash_flows
  end

  def get_invoice
    render json: @folder.cash_flows, each_serializer: ClientsApi::V1::InvoiceSerializer
  end

  def get_contract
    contract_document = @folder.contract_document
    return render json: custom_json({ message: "Contrato no disponible" }) unless contract_document.present?
    send_data contract_document, filename: "Contrato", type: "application/pdf", disposition: "inline"
  end

  def get_nom
    nom_document = @folder.nom_document
    return render json: custom_json({ message: "NOM-151 no disponible" }) unless nom_document.present?
    send_data nom_document, filename: "NOM-151", type: "application/pdf", disposition: "inline"
  end

  def invoice
    invoice = @cash_flow.to_file(false, false, false)
    send_data invoice.to_pdf, filename: "invoice.pdf", type: "application/pdf", disposition: "attachment"
  end
  private

    def set_folder
      @folder = current_user.client.folders.find(params[:id])
    end

    def set_cash_flow
      @cash_flow = @folder.cash_flows.find(params[:cash_flow_id])
    end
end
