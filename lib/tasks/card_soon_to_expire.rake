# frozen_string_literal: true

namespace :card_soon_to_expire do
  desc "Run card_soon_to_expire task"

  task run: :environment do
    link_expiration_in_hours = Setting.find_by(key: :link_expiration_for_card_expire)&.value
    reminder_settings = Setting.find_by(key: :card_soon_to_expire)&.value

    raise "Missing link_expiration_in_hours setting" unless link_expiration_in_hours.present?
    raise "Missing reminder_settings setting" unless reminder_settings.present?

    reminder_settings = reminder_settings.value.split(',')

    Subscription.where(status: Subscription::STATUS[:ACTIVE]).includes(:folder).each do |subscription|
      if subscription.exp_year == Time.zone.now.strftime("%y").to_i && subscription.exp_month == Time.zone.now.next_month.strftime("%m").to_i && reminder_settings.include?(Time.zone.now.strftime("%d").to_i)
        project = subscription.folder.lot.project
        SubscriptionMailer.card_soon_to_expire(subscription.folder.client.email, subscription.folder.client, subscription, project.project_entity_name, project.phase_entity_name,project.stage_entity_name).deliver_later
      end
    end
  end
end
