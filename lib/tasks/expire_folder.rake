# frozen_string_literal: true

namespace :expire_folder do
  desc "Run expire folder task"

  task :run, [:initial_payment, :down_payment, :run] => [:environment] do |task, args|
    exit if its_weekend?

    expire_initial_payment = (args[:initial_payment] == "true")
    expire_down_payment = (args[:down_payment] == "true")
    dry = (args[:run] == "false")
    expired = []

    Folder.includes(:payment_scheme, documents: [:document_template], lot: { stage: { phase: :project } })
      .joins(:step)
      .where("steps.folders_expires = (?) AND folders.status = (?)", true, Folder::STATUS[:ACTIVE])
      .each do |folder|
      initial_payment = folder.documents.with_custom_action("initial_payment").take.try(:attached?)
      initial_payment_complement = folder.documents.with_custom_action("initial_payment_complement").take.try(:attached?)
      down_payment = folder.documents.with_custom_action("down_payment").take.try(:attached?)

      if !initial_payment || !initial_payment_complement || !down_payment
        hours_passed = (Time.zone.now.to_time - folder.calc_date.to_time) / 1.hours

        initial_payment_expiration = folder.stage.initial_payment_expiration.present? ? folder.stage.initial_payment_expiration : 72 # hours alias to 3 days
        initial_payment_expiration += folder.initial_payment_sudden_death if folder.initial_payment_sudden_death.present?

        total_down_payment_expiration = folder.stage.down_payment_expiration.present? ? folder.stage.down_payment_expiration : 240 # hours alias to 10 days
        total_down_payment_expiration += folder.down_payment_sudden_death if folder.down_payment_sudden_death.present?

        needs_to_be_expire = false
        needs_complement = (folder.payment_scheme.complement_payment > 0)

        if needs_complement && !initial_payment && !initial_payment_complement && folder.payment_scheme.online_payment_id.nil? && initial_payment_expiration <= hours_passed && expire_initial_payment
          # We validate if is within the first period -> 3 days
          needs_to_be_expire = true
          reason = "Sin apartado completo y sin comprobante de enganche"
        elsif !initial_payment && folder.payment_scheme.online_payment_id.nil? && initial_payment_expiration <= hours_passed && expire_initial_payment
          # We validate if is within the first period -> 3 days
          needs_to_be_expire = true
          reason = "Sin comprobante de apartado y sin comprobante de enganche"
        elsif !down_payment && !folder.payment_scheme.down_payment_paid && total_down_payment_expiration <= hours_passed && expire_down_payment
          # We validate if is within the second period -> 3 days + 7 days
          needs_to_be_expire = true
          reason = "Sin comprobante de enganche"
        end

        if needs_to_be_expire && folder.stage.is_expirable
          puts "Expediente: #{folder.id}"
          puts "Proyecto: #{folder.project.name}"
          puts "Fase: #{folder.phase.name}"
          puts "Etapa: #{folder.stage.name}"
          puts "Lote: #{folder.lot.name}"
          puts "Fecha de inicio: #{folder.calc_date}"
          puts "Horas desde inicio: #{hours_passed}"
          puts "Motivo: #{reason}"
          puts "======="

          expired << {
              folio: folder.id,
              project: folder.project.name,
              phase: folder.phase.name,
              stage: folder.stage.name,
              lot: folder.lot.name,
              start_date: folder.calc_date.strftime("%d/%m/%Y %I:%M%p"),
              hours_from_start: hours_passed.round(2),
              reason: reason
          }

          if !dry && !folder.expire
            Bugsang.notify("Expediente #{folder.id} no pudo ser expirado")
          end
        end
      end
    end

    if !dry && expired.any?
      expired_notification_emails = Setting.find_by(key: "expired_notification_emails")&.value
      if expired_notification_emails.present?
        emails = expired_notification_emails.split(",")
        emails.each do |email|
          FolderMailer.notify_expiration(email, expired.to_json, Time.zone.now.strftime("%d/%m/%Y %I:%M%p")).deliver_later
        end
      end
    end
  end

  def its_weekend?
    Time.zone.now.on_weekend?
  end
end
