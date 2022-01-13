# frozen_string_literal: true

module SignatureServiceConcern
  extend ActiveSupport::Concern
  def set_signer_structure(signer, role, coordinates, is_shield_level_three, isNotNegotiator = false, isNotSigner = false)
    obligation = get_signer_obligation_type(signer)

    signer_data = {
      obligation: obligation,
      name: signer.name,
      role: role,
      email: signer.email,
      coordinates: coordinates,
      is_shield_level_three: is_shield_level_three,
      isNotNegotiator: isNotNegotiator,
      isNotSigner: isNotSigner
    }

    if obligation.to_sym == :individual
      signer_data.merge!(last_name: signer.first_surname)
    else
      signer_data.merge!(representative: signer.moral_client&.legal_name)
    end

    signer_data
  end

  def get_signer_obligation_type(signer)
    return signer.person.to_sym == :physical ? "individual" : "legal" if signer.class == Client
    "individual"
  end

  def get_signature_coordinates(signer, pages)
    pages.map { |page|page if page[:text] == signer }.compact
  end

  def create_digital_signature(folder, digital_signature_service, document_type)
    DigitalSignature.create(folder: folder, service_type: digital_signature_service.name, document_type: document_type, status: DigitalSignature.statuses[:initialized], digital_signature_service: digital_signature_service, date: Time.zone.now)
  end

  def update_digital_signature(folder, file_name, digital_signature_service, document, digital_signature, signers_array)
    creator = digital_signature_service.creator
    document_hash = creator.init_process("#{file_name}.pdf", document, "#{folder.id}-#{digital_signature.document_type}", signers_array, false, digital_signature_service.shield_level_three_message)

    return digital_signature.update(status: DigitalSignature.statuses[:failed], error_description: "Error al enviar la promesa de compra") unless document_hash["success"]

    digital_signature.update(response_data: { participants: document_hash["contract"]["participants"] },
                             document_external_id: document_hash["contract"]["_id"],
                             status: DigitalSignature.statuses[:sent_to_clients_signature],
                             sent_to_clients: true,
                             date: Time.zone.now)
  end

  def get_digital_signature(folder, digital_signature_service)
    last_digital_signature = folder.digital_signatures.failed.order(date: :asc).last
    if last_digital_signature.present?
      last_digital_signature.update(status: DigitalSignature.statuses[:initialized], error_description: nil)
      digital_signature = last_digital_signature
    else
      digital_signature = create_digital_signature(folder, digital_signature_service, DigitalSignature.document_types[:purchase_promise])
    end
    digital_signature
  end

  def update_participant_status(digital_signature)
    digital_signature_service = digital_signature.digital_signature_service
    service = digital_signature_service.creator
    digital_signature.digital_signature_participants.received_to_sign.order(:recipient_type).each do |participant|
      participant_response = service.get_participant_status(digital_signature.document_external_id, participant.participant_id)
      next unless participant_response["information"]["status"]
      participant.update(status: participant_response["information"]["status"])
    end
  end

  def update_digital_signature_status(digital_signature)
    return unless digital_signature.document_external_id.present?

    if digital_signature.initialized? || digital_signature.sent_to_clients_signature? || digital_signature.sent_for_signature_of_legal_representatives?

      service = digital_signature.digital_signature_service.creator
      return unless service.authorize_bearer["success"]

      get_status = service.get_status(digital_signature.document_external_id)
      update_participant_status(digital_signature)

      if get_status["status"].present?
        change_status(get_status["status"], digital_signature)
      end

    end
  rescue StandardError => ex
    Bugsnag.notify(ex) do |report|
      report.add_tab(:trato_error_response, ex)
    end
  end

  def change_status(status, digital_signature)
    case status
    when TratoService::STATUSES[:RECEIVED_SIGNED]
      digital_signature.update(status: DigitalSignature.statuses[:finalized], system_over_user: true)
    when TratoService::STATUSES[:EXPIRED]
      digital_signature.update(status: DigitalSignature.statuses[:expired], system_over_user: true)
    when TratoService::STATUSES[:FINALIZED]
      digital_signature.update(status: DigitalSignature.statuses[:finalized], system_over_user: true)
    when TratoService::STATUSES[:CANCELED]
      digital_signature.update(status: DigitalSignature.statuses[:canceled], system_over_user: true)
    end
  end
end
