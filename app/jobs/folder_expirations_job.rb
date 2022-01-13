# frozen_string_literal: true

class FolderExpirationsJob < ApplicationJob
  def perform(folder_id, documents_to_check = [])
    folder = Folder.find(folder_id)

    documents = documents_to_check.map do |doc|
      { document: folder.documents.with_custom_action(doc).take, action: doc }
    end

    missing_documents = documents.filter do |doc_obj|
      !(doc_obj[:document].try(:attached?) && !folder.payment_scheme.payment_confirmed_for?(doc_obj[:action]))
    end

    if missing_documents.any? && folder.stage.is_expirable && folder&.step&.folders_expires
      missing_doc_names = missing_documents.map do |missing_doc|
        missing_doc[:action]
      end

      reason = "Faltan los siguientes documentos: #{missing_doc_names.join(', ')}."

      hours_passed = (Time.zone.now.to_time - folder.calc_date.to_time) / 1.hours

      expired = [{
        folio: folder.id,
        project: folder.project.name,
        phase: folder.phase.name,
        stage: folder.stage.name,
        lot: folder.lot.name,
        start_date: folder.calc_date.strftime("%d/%m/%Y %I:%M%p"),
        hours_from_start: hours_passed.round(2),
        reason: reason
      }]

      unless folder.expire
        Bugsang.notify("Expediente #{folder.id} no pudo ser expirado")
      end

      expired_notification_emails = Setting.find_by(key: "expired_notification_emails")&.value

      if expired_notification_emails.present?
        emails = expired_notification_emails.split(",")
        emails.each do |email|
          FolderMailer.notify_expiration(email, expired.to_json, Time.zone.now.strftime("%d/%m/%Y %I:%M%p")).deliver_later
        end
      end
    end
  end
end
