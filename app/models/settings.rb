# frozen_string_literal: true

# RailsSettings Model
class Settings < RailsSettings::Base
  self.table_name = "settings"
  cache_prefix { "v1" }

  # Define your fields
  field :project_singular, type: :string, default: "Proyecto"
  field :phase_singular, type: :string, default: "Fase"
  field :stage_singular, type: :string, default: "Etapa"
  field :lot_singular, type: :string, default: "Lote"
  field :slack_subscription_notifs_hook, type: :string
end
