# frozen_string_literal: true

class StepLog < ApplicationRecord
  include SignatureServiceConcern
  STATUS = Folder::STATUS

  scope :created_at_asc, ->() { order(created_at: :asc) }

  enum status: { active: "active", expired: "expired", canceled: "canceled" }
  enum action: { reactivate: "reactivate", approve: "approve", soft_reject: "soft_reject", refuse: "refuse", cancel: "cancel", expire: "expire"   }

  belongs_to :step, required: false, with_deleted: true
  belongs_to :folder
  belongs_to :user, required: false

  after_create :notify

  private

    def notify
      folder_step_logs = folder.step_logs.order(moved_at: :asc)
      current_step_index = folder_step_logs.index(self)
      prev_step_log = folder_step_logs[current_step_index - 1] unless current_step_index == 0

      if soft_reject? && folder.active_mails
        AutomatedEmail.where(
          step: step,
          execution_type: AutomatedEmail.executions[:back_step]
        ).each do |enter_email|
          AutomatedEmailMailer.send_automated_email(folder, enter_email).deliver_later
        end
      end
      if soft_reject? && folder.has_pending_purchase_promise_signatures?
        last_digital_signature = folder.get_digital_signature
        if last_digital_signature.present?
          last_digital_signature.update(status: DigitalSignature.statuses[:canceled])
        end
      end

      if refuse? && folder.active_mails
        AutomatedEmail.where(
          step: step,
          execution_type: AutomatedEmail.executions[:reject_step]
        ).each do |enter_email|
          AutomatedEmailMailer.send_automated_email(folder, enter_email).deliver_later
        end
      end

      return if refuse? || soft_reject?

      # Enters a new step. Could be the first one, second one or even the last one.
      if step.present?

        send_digital_signature(folder, step)

        if folder.active_mails
          AutomatedEmail.where(
            step: step,
            execution_type: AutomatedEmail.executions[:enter_step]
          ).each do |enter_email|
            AutomatedEmailMailer.send_automated_email(folder, enter_email).deliver_later
          end
        end
      end

      # Exits the current step. Could be the first one, second one or even the last one.
      if prev_step_log.present? && prev_step_log.step.present? && folder.active_mails
        AutomatedEmail.where(
          step: prev_step_log.step,
          execution_type: AutomatedEmail.executions[:exit_step]
        ).each do |enter_email|
          AutomatedEmailMailer.send_automated_email(folder, enter_email).deliver_later
        end
      end

      # Exits a hidden state. Could be the expired or canceled.
      if prev_step_log.present? && prev_step_log.step.nil? && folder.active_mails
        AutomatedEmail.where(
          hidden_state: prev_step_log.status,
          execution_type: AutomatedEmail.executions[:exit_step]
        ).each do |automated_email|
          AutomatedEmailMailer.send_automated_email(folder, automated_email).deliver_later
        end
      end

      # Enters a hidden state. Could be the expired or canceled.
      if step.nil? && folder.active_mails
        AutomatedEmail.where(
          hidden_state: status,
          execution_type: AutomatedEmail.executions[:enter_step]
        ).each do |automated_email|
          AutomatedEmailMailer.send_automated_email(folder, automated_email).deliver_later
        end
      end
    end

    def send_digital_signature(folder, step)
      dss = folder.digital_signature_services.first
      if dss.present? && dss.step.present? && dss.step == step && dss.is_automatic
        digital_signature = get_digital_signature(folder, dss)
        PurchasePromiseSignatureServiceJob.perform_later(folder, dss, digital_signature)
      end
    end
end
