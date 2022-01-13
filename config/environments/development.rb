# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp", "caching-dev.txt").exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
        "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  # config.active_storage.service = :amazon
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  if ENV["MAILCATCHER"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = { address: "127.0.0.1", port: 1025 }
  elsif ENV["POSTMARK_API_KEY"].present?
    config.action_mailer.delivery_method = :postmark
    config.action_mailer.postmark_settings = {
      api_token: ENV["POSTMARK_API_KEY"]
    }
  elsif ENV["MAILGUN_API_KEY"].present? && ENV["MAILGUN_DOMAIN"].present?
    config.action_mailer.delivery_method = :mailgun
    config.action_mailer.mailgun_settings = {
      api_key: ENV["MAILGUN_API_KEY"],
      domain: ENV["MAILGUN_DOMAIN"],
    }
  else
    config.action_mailer.delivery_method = :letter_opener
  end
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_options = { from: Rails.application.secrets.app_emailer }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }
  Rails.application.routes.default_url_options[:host] = "localhost:3000"

  config.exceptions_app = self.routes

  ISO3166.configure do |config|
    config.locales = [:es]
  end

  config.action_controller.asset_host = "http://localhost:3000"
  config.action_mailer.asset_host = config.action_controller.asset_host

  config.textris_delivery_method = :mail

  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.rails_logger = true
    Bullet.add_footer = true
  end

  # config.secrets.secret_key_base = "a13640e1e9c3eda4afabc165a92a4dabb11408c80dc0fc92ccfcb45f9902b56f437ab910c13bdb0db49198d85ee726aaa67d50b08aed86e3a4fc998f975679b4"
end
