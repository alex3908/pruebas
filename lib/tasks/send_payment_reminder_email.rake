# frozen_string_literal: true

namespace :send_payment_reminder_email do
  desc "send_payment_reminder_email"

  task run: :environment do
    payment_reminder_settings = Setting.find_by(key: :payment_due_soon)
    if payment_reminder_settings.present? && payment_reminder_settings.value.present?
      payment_reminders = payment_reminder_settings.value.split(",")
      installments_steps = Step.where(send_payment_reminder: true).pluck(:id)
      Folder.includes(:payment_scheme, documents: [:document_template], lot: { stage: { phase: :project } })
          .joins(:step)
          .where("steps.id IN (?) AND folders.reminders_enabled = 't' AND folders.status = (?)", installments_steps, Folder::STATUS[:ACTIVE])
          .each do |folder|
        installment = folder.installments.where("EXTRACT(MONTH FROM date) = ? AND EXTRACT(YEAR FROM date ) = ?", Time.zone.now.strftime("%m"), Time.zone.now.strftime("%Y")).first
        next if installment.nil?
        payment_reminders.each do |payment_reminder|
          reminder_day = installment.date.prev_day(payment_reminder.to_i)
          if Time.zone.now.to_date == reminder_day.to_date
            if installment.number.to_i <= folder.installments.length
              PaymentMailer.payment_due_soon(folder.client.email, folder.client, folder, installment.date.day).deliver_later
            end
          end
        end
      end
    end
  end
end
