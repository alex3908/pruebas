# frozen_string_literal: true

class SubscriptionMailerPreview < ActionMailer::Preview
  def subscription_invitation
    folder = Folder.fourth
    project = folder.lot.project
    SubscriptionMailer.subscription_invitation(folder.client.email, folder.client, folder, Faker::Invoice.reference, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def confirm_subscription
    folder = Folder.fourth
    project = folder.lot.project
    SubscriptionMailer.confirm_subscription(folder.client.email, folder.client, folder, Time.zone.now.strftime("%d"), project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def confirm_update_subscription
    folder = Folder.fourth
    project = folder.lot.project
    SubscriptionMailer.confirm_update_subscription(folder.client.email, folder.client, folder, Time.zone.now.strftime("%d"), project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def confirm_subscription_payment
    folder = Folder.fourth
    project = folder.lot.project
    SubscriptionMailer.confirm_subscription_payment(folder.client.email, fake_pdf, folder.client, folder.subscription, 5000, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def subscription_payment_error
    folder = Folder.fourth

    SubscriptionMailer.subscription_payment_error(folder.client.email, folder.client, folder, 5000)
  end

  def card_soon_to_expire
    folder = Folder.fourth
    project = folder.lot.project
    SubscriptionMailer.card_soon_to_expire(folder.client.email, folder.client, folder.subscription, Faker::Invoice.reference, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  def subscription_soon_to_finish
    folder = Folder.fourth
    project = folder.lot.project
    SubscriptionMailer.subscription_soon_to_finish(folder.client.email, folder.client, folder.subscription, project.project_entity_name, project.phase_entity_name, project.stage_entity_name)
  end

  private
    # ToDo: Replace with real quotation
    def fake_pdf
      "<html><body><h1 align='center'>Test Document</h1></body></html>"
    end
end
