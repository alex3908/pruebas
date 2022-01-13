# frozen_string_literal: true

namespace :create_digital_signature_participants do
  desc "Create digital signature participants"

  task run: :environment do
    DigitalSignature.all.each do |digital_signature|
      if digital_signature.response_data.present? && digital_signature.digital_signature_service.present?
        digital_signature.response_data["participants"].each do |participant|
          participant_type = get_participant_type_for_task(participant["email"])
          participant_status = participant_status(digital_signature, participant_type, participant["_id"])
          DigitalSignatureParticipant.create(digital_signature: digital_signature,
                                             participant_id: participant["_id"],
                                             email: participant["email"],
                                             sign_url: participant["signUrl"],
                                             recipient_type: participant_type,
                                             status: participant_status[:status],
                                             email_send: participant_status[:email_send])
        end

      end
    end
  end

    private

      def get_participant_type_for_task(email)
        client = Client.find_by_email(email)
        signer = Signer.find_by_email(email)

        if client.present?
          return DigitalSignatureParticipant.recipient_types[:client]
        end

        if signer.present?
          signer.is_an_observer ? DigitalSignatureParticipant.recipient_types[:observer] : DigitalSignatureParticipant.recipient_types[:representative]
        end
      end

      def participant_status(digital_signature, participant_type, participant_id)
        participant_state = { status: DigitalSignatureParticipant.statuses[:received_to_sign], email_send: false }
        service = digital_signature.digital_signature_service.creator

        if digital_signature.sent_to_clients_signature? && participant_type == DigitalSignatureParticipant.recipient_types[:client]
          participant_response = service.get_participant_status(digital_signature.document_external_id, participant_id)
          participant_state[:status] = participant_response["information"]["status"]
          participant_state[:email_send] = true
        elsif digital_signature.sent_for_signature_of_legal_representatives?
          if participant_type == DigitalSignatureParticipant.recipient_types[:client]
            participant_state[:status] = DigitalSignatureParticipant.statuses[:sent_signed]
            participant_state[:email_send] = true
          elsif participant_type == DigitalSignatureParticipant.recipient_types[:representative]
            participant_response = service.get_participant_status(digital_signature.document_external_id, participant_id)
            participant_state[:status] = participant_response["information"]["status"]
            participant_state[:email_send] = true
          elsif participant_type == DigitalSignatureParticipant.recipient_types[:observer]
            participant_state[:email_send] = false
          end
        elsif digital_signature.finalized?
          participant_state[:status] = DigitalSignatureParticipant.statuses[:sent_signed]
          participant_state[:email_send] = true
        end
        participant_state
      end
end
