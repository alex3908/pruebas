# frozen_string_literal: true

module HubspotConcern
  extend ActiveSupport::Concern

  def is_hubspot_enabled?
    Rails.application.secrets.hubspot_apikey.present?
  end

  def is_not_hubspot_enabled?
    !is_hubspot_enabled?
  end

  def same_owner(contact, owner)
    return false if owner.nil?
    contact.present? && contact.properties[:hubspot_owner_id] != owner.try(:owner_id).try(:to_s)
  end
end
