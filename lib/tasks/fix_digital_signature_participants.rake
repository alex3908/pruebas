# frozen_string_literal: true

namespace :fix_digital_signature_participants do
  desc "fix digital signature participants"

  task run: :environment do
    include SignatureServiceConcern
    statuses = DigitalSignature.statuses

    GATEWAY_URLS = {
        "production" => "https://enterprise.app.trato.io",
        "test" => "https://enterprise-stage.app.trato.io"
    }

    DigitalSignature.where.not(status: [ statuses[:expired], statuses[:canceled], statuses[:finalized]]).each do |digital_signature|
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
        participant = digital_signature.digital_signature_participants.first
        service = digital_signature.digital_signature_service.creator

        if participant.present?
          document_external_id = participant.sign_url.gsub(GATEWAY_URLS[digital_signature.digital_signature_service.environment] + "/sign/", "").split("/")[0]

          get_status = service.get_status(document_external_id)

          unless get_status["success"].present? && get_status["success"] == false
            service.cancel_process(document_external_id) if get_status["status"] == TratoService::STATUSES[:SENT_TO_SIGN]
          end
        end

        digital_signature.digital_signature_participants.destroy_all
        digital_signature.touch

      end
    end
  end
end
