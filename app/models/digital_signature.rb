# frozen_string_literal: true

class DigitalSignature < ApplicationRecord
  attr_accessor :system_over_user
  enum status: { initialized: "initialized", created: "created", sent_to_clients_signature: "sent_to_clients_signature", sent_for_signature_of_legal_representatives: "sent_for_signature_of_legal_representatives", expired: "expired", canceled: "canceled", finalized: "finalized", failed: "failed" }
  enum document_type: { purchase_promise: "purchase_promise", folder_documents: "folder_documents" }

  belongs_to :folder
  belongs_to :digital_signature_service, with_deleted: true
  has_many :digital_signature_participants
  has_many :digital_signature_logs
  validate :cancel_digital_signature, if: :can_cancel_document?
  validate :finalize_document, if: :can_finalize_document?
  after_update :save_participants, unless: :have_participants?
  after_update :send_clients_email, if: :can_send_to_clients?
  after_save :create_signature_log
  after_touch :save_participants, unless: :have_participants?
  after_touch :send_clients_email, if: :can_send_to_clients?


  def signature_label
    I18n.t("digital_signatures.statuses.#{self.status}")
  end


  def all_clients_have_signed?
    all_clients = digital_signature_participants.client
    clients_signed = all_clients.sent_signed
    all_clients == clients_signed
  end


  private

    def have_participants?
      digital_signature_participants.any?
    end

    def can_send_to_clients?
      digital_signature_participants.client.where(email_send: false).any?
    end

    def can_finalize_document?
      finalized?
    end

    def can_cancel_document?
      canceled?
    end

    def save_participants
      if response_data.present?
        response_data["participants"].each do |participant|
          DigitalSignatureParticipant.create(digital_signature: self,
                                             participant_id: participant["_id"],
                                             email: participant["email"],
                                             sign_url: participant["signUrl"],
                                             recipient_type: get_participant_type(participant["email"]),
                                             status: DigitalSignatureParticipant.statuses[:received_to_sign])
        end
      end
    end

    def get_participant_type(email)
      ruled_contract = folder.ruled_contract
      clients = folder.clients.map { |client| client.email }
      return DigitalSignatureParticipant.recipient_types[:client] if clients.include?(email)
      signers = ruled_contract.signers.map { |signer| signer.email }
      return DigitalSignatureParticipant.recipient_types[:representative] if signers.include?(email)
      observers = ruled_contract.non_signers.map { |observer| observer.email }
      return DigitalSignatureParticipant.recipient_types[:observer] if observers.include?(email)
    end

    def send_clients_email
      digital_signature_participants.client.where(email_send: false).each do |participant|
        participant.update_attributes(email_send: true)
        DigitalSignatureMailer.send_signature_addresses(folder, participant).deliver_later
      end
    end

    def finalize_document
      service = digital_signature_service.creator
      finalized_response = service.finalize_process(document_external_id)
      if finalized_response["success"]
        if digital_signature_service.jump_to_step && digital_signature_service.jump_step_id.present? && document_type == document_types[:purchase_promise]
          folder.update(step_id: digital_signature_service.jump_step_id)
        end
        pdf = finalized_response["contract"]["downloadPdfUrl"]
        pdf_nom = finalized_response["contract"]["nom151"]

        send_signed_document_email(pdf, pdf_nom)
        attach_document(pdf, digital_signature_service.document_template_id)
        attach_document(pdf_nom, digital_signature_service.document_nom_id)

      else
        errors.add("Error al finalizar el documento")
      end
    rescue StandardError => ex
      Bugsnag.notify(ex) do |report|
        report.add_tab(:trato_error_response, ex)
      end
      errors.add("Error al finalizar el documento")
    end

    def send_signed_document_email(pdf, pdf_nom)
      digital_signature_participants.each do |participant|
        representative_legal = Signer.find_by(email: participant.email)
        if representative_legal.present?
          DigitalSignatureMailer.send_signed_document_to_legal_representative(folder, pdf, participant.email, representative_legal).deliver_later
        else
          DigitalSignatureMailer.send_signed_document(folder, pdf, pdf_nom, participant.email).deliver_later
        end
      end
      DigitalSignatureMailer.send_signed_document_to_user(folder).deliver_later
    end

    def send_nom_email(document_link)
      digital_signature_participants.client.each do |participant|
        DigitalSignatureMailer.send_nom_document(folder, participant, document_link).deliver_later
      end
    end

    def attach_document(pdf, template_id)
      document = folder.documents.find_by(document_template_id: template_id)
      if !document.nil? && digital_signature_service.document_template.present?
        file_version = FileVersion.create(document: document)
        file_version.file.attach(io: open(pdf), filename: File.basename(pdf), content_type: "application/pdf")
      end
    rescue StandardError => ex
      Bugsnag.notify(ex) do |report|
        report.add_tab(:trato_error_response, ex)
      end
    end

    def cancel_digital_signature
      if document_external_id.present?
        service = digital_signature_service.creator
        get_status = service.get_status(document_external_id)
        errors.add(:status, :cancel_error) if get_status["success"].present? && get_status["success"] == false
        if get_status["status"] == TratoService::STATUSES[:SENT_TO_SIGN]
          unless service.cancel_process(document_external_id)
            errors.add(:status, :cancel_error)
          end
        elsif get_status["status"] == TratoService::STATUSES[:FINALIZED]
          errors.add(:status, :not_cancel_finalized_error)
        end
      end
    rescue StandardError => ex
      Bugsnag.notify(ex) do |report|
        report.add_tab(:trato_error_response, ex)
      end
      errors.add(:status, :cancel_error)
    end

    def create_signature_log
      DigitalSignatureLog.create(digital_signature: self, user: system_over_user ? nil : Current&.user, status: self.status, date: Time.zone.now)
    end
end
