# frozen_string_literal: true

namespace :subscription_soon_to_finish do
  desc "Run subscription_soon_to_finish task"

  task run: :environment do
    reminder_settings = Setting.find_by(key: :subscription_soon_to_finish)&.value
    raise "Missing subscription_soon_to_finish setting" unless reminder_settings.present?
    reminder_settings = reminder_settings.split(',')

    settings = Setting.where(key: [
        "company-url"
    ])

    home_page = settings.select { |setting| setting.key == "home-page" }.first&.value

    Subscription.where(status: Subscription::STATUS[:ACTIVE]).includes(folder: { lot: { stage: { phase: :project } } } ).each do |subscription|
      reminder_settings.each do |reminder|
        if subscription.billing_end.to_date == Time.zone.now.next_day(reminder.to_i).to_date
          folder = subscription.folder
          project = folder.lot.project
          if folder.stage.payment_receptor_emails.present?
            folder.stage.payment_receptor_emails.each do |email|
              SubscriptionMailer.subscription_soon_to_finish(email, subscription.client, subscription,project.project_entity_name,project.phase_entity_name,project.stage_entity_name).deliver_later
            end
          end
        end
      end
    end
  end
end
  