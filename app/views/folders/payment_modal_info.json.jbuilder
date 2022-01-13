# frozen_string_literal: true

json.canSendByWhatsapp @can_send_by_whatsapp
json.canSendByEmail @can_send_by_email
json.canCopyToClipboard @can_copy_to_clipboard
json.canSuscribe @can_suscribe
json.cannotPerformSubscription @cannot_perform_subscription
json.canCancelSubscription @can_cancel_subscription
json.canUpdateSuscription @can_update_suscription
json.activeSuscription @active_suscription
json.clients do
  json.array! @clients do |client|
    json.text client.label
    json.id client.id
    json.phone client.main_phone
    json.email client.email
  end
end
json.subscriptionItems do
  json.array! @suscription_items do |suscription_item|
    json.id suscription_item.id
    json.subscription_id suscription_item.subscription_id
    json.status suscription_item.status_label
  end
end
json.gatewayTypes do
  json.array! @gateway_types do |gateway_type|
    json.id gateway_type[:id]
    json.text gateway_type[:text]
  end
end
