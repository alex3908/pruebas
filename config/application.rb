# frozen_string_literal: true

require_relative "boot"

require "rails"

# Include each railties manually, excluding `active_storage/engine`
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AdaraCRM
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    if Rails.env.development?
      config.web_console.whitelisted_ips = ["172.16.0.0/12", "192.168.0.0/16"]
    end

    config.serve_static_assets = true

    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("lib/concerns")
    config.autoload_paths += Dir["#{Rails.root}/lib/remote_services/**/"]

    config.eager_load_paths << Rails.root.join("lib")
    config.eager_load_paths << Rails.root.join("lib/concerns")

    config.eager_load_paths += Dir["#{Rails.root}/lib/remote_services/**/"]

    config.autoload_paths << "#{Rails.root}/app/auth/authenticate_user"

    I18n.enforce_available_locales = false
    I18n.config.available_locales = :es
    config.i18n.default_locale = :es

    config.time_zone = "America/Mexico_City"
    config.active_record.default_timezone = :local

    # Enable activejob
    config.active_job.queue_adapter = :delayed_job

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins "*"
        resource "*", headers: :any,
        methods: [:get, :post, :options]
      end
    end

    config.to_prepare do
      # Configure single controller layout
      Devise::Mailer.layout "mailer"
    end
  end
end
