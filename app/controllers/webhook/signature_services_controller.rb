# frozen_string_literal: true

class Webhook::SignatureServicesController < Webhook::BaseController
  include SignatureServiceConcern
  def sign_event
    return render json: { status: :ok } if params[:externalId] == "TEST ID"

    digital_signature = DigitalSignature.find_by_document_external_id(params[:contractid])

    return render json: { status: :ok } unless digital_signature.present?

    update_digital_signature_status(digital_signature)

    render json: { status: :ok }
  rescue StandardError => ex
    render json: { error: ex.message }, status: :bad_request
  end
end
