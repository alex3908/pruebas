# frozen_string_literal: true

namespace :check_digital_signature_status do
  task run: :environment do
    include SignatureServiceConcern
    GATEWAY_URLS = {
      "production" => "https://enterprise.app.trato.io",
      "test" => "https://enterprise-stage.app.trato.io"
    }

    statuses = DigitalSignature.statuses
    ACTIVE_STATUSES = [statuses[:initialized], statuses[:sent_to_clients_signature], statuses[:sent_for_signature_of_legal_representatives]]

    set_digital_signature_date
    check_digital_signature_participants
    check_status
  end

  def check_status
    digital_signatures = DigitalSignature.all
    Folder.where(id: digital_signatures.pluck(:folder_id)).each do |folder|
      folder_digital_signatures = folder.digital_signatures
      check_only_one_active(folder_digital_signatures)
      folder_digital_signatures.each do |digital_signature|
        update_digital_signature_status(digital_signature)
      end
    end
  end

  def check_only_one_active(digital_signatures)
    active_ds = digital_signatures.where(status: ACTIVE_STATUSES).order(date: :asc)
    if active_ds.size > 1
      last_active = active_ds.last
      active_ds.where.not(id: last_active.id).each do |digital_signature|
        digital_signature.update(status: DigitalSignature.statuses[:canceled])
      end
    end
  end

  def check_digital_signature_participants
    inconsistency_detected = false
    DigitalSignature.where(status: ACTIVE_STATUSES).each do |digital_signature|
      participants_parent = []
      has_difference = false

      if digital_signature.response_data.present?
        participants_parent = digital_signature.response_data["participants"].map { |participant|participant["_id"] }.compact
      end

      digital_signature.digital_signature_participants.each do |participant|
        unless participants_parent.include?(participant.participant_id)
          has_difference = true
          break
        end
      end

      if has_difference
        inconsistency_detected = true
        digital_signature.digital_signature_participants.destroy_all
        digital_signature.touch
      end
    end
    check_data_consistency if inconsistency_detected
  end

  def check_data_consistency
    digital_signatures_document_ids = DigitalSignature.pluck(:document_external_id)
    DigitalSignatureService.unscoped.each do |digital_signature_service|
      service = digital_signature_service.creator
      raw_list = service.list_contracts
      processed = raw_list.select { |document| document["status"] == TratoService::STATUSES[:SENT_TO_SIGN] }
      processed.each do |active_document|
        if digital_signatures_document_ids.exclude? active_document["_id"]
          service.cancel_process(active_document["_id"])
        end
      end
    end
  end

  def set_digital_signature_date
    list = []
    digital_signatures = DigitalSignature.where(date: nil)
    return if digital_signatures.empty?
    DigitalSignatureService.unscoped.each do |digital_signature_service|
      service = digital_signature_service.creator
      list << service.list_contracts.map { |document|{ id: document["_id"], created_at: document["createdAt"] } }
    end

    processed_list = list.flatten.uniq

    digital_signatures.each do |digital_signature|
      if digital_signature.document_external_id.present?
        persisted_contract = processed_list.find { |i| i[:id] == digital_signature.document_external_id }
        if persisted_contract.present?
          digital_signature.update_columns({ date: persisted_contract[:created_at].to_datetime })
        end
      else
        digital_signature.update(date: Time.zone.now, status: DigitalSignature.statuses[:canceled])
      end
    end
  end
end
