# frozen_string_literal: true

class DigitalSignatureParticipant < ApplicationRecord
  belongs_to :digital_signature
  before_save :send_sign_notification_email, if: :can_send_notification_email?
  after_update :update_signature_status, if: :can_update_signature_status?
  after_update :send_to_representative, if: :can_send_to_representative?

  enum status: { received_to_sign: "RECEIVED_TO_SIGN", sent_signed: "SENT_SIGNED" }
  enum recipient_type: { client: "Client", representative: "Representative", observer: "Observer" }

  def name
    participant = system_participant

    return "" unless participant.present?
    participant.label
  end

  def phone
    participant = system_participant
    if participant.present? && participant.class.name == Client.name
      participant.main_phone
    else
      participant.phone
    end
  end

    private

      def system_participant
        client? ? Client.find_by(email: email) : Signer.find_by(email: email)
      end

      def can_send_to_representative?
        digital_signature.all_clients_have_signed? && received_to_sign? && !email_send && (representative? || observer?)
      end

      def can_update_signature_status?
        digital_signature.all_clients_have_signed? && !digital_signature.sent_to_representatives
      end

      def can_send_notification_email?
        client? && status_changed?(from: "received_to_sign", to: "sent_signed")
      end

      def update_signature_status
        digital_signature.update_attributes!({ status: DigitalSignature.statuses[:sent_for_signature_of_legal_representatives], sent_to_representatives: true })
      end

      def send_to_representative
        if representative?
          self.update_attributes(email_send: true)
          DigitalSignatureMailer.send_signature_to_legal_representative(digital_signature.folder, self).deliver_later
        elsif observer?
          self.update_attributes(email_send: true)
          DigitalSignatureMailer.send_signature_to_observer(digital_signature.folder, self).deliver_later
        end
      end

      def send_sign_notification_email
        folder = digital_signature.folder
        representative_participants = digital_signature.digital_signature_participants.where(recipient_type: DigitalSignatureParticipant.recipient_types.values_at(:representative, :observer))
        representative_participants.each do |participant|
          DigitalSignatureMailer.send_sign_notification(folder, self, participant).deliver_later
        end
      end
end
