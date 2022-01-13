# frozen_string_literal: true

Bugsnag.configure do |config|
  config.app_version = "4.4.1"
  config.api_key = Rails.application.secrets.bugsnag || "f75a6fff104b1a61ec4ba3e31ac4b63b"
  config.notify_release_stages = ["production", "staging"]
  config.release_stage = ENV["BUGSNAG_ENV"].presence || ENV["RAILS_ENV"].presence || ENV["RACK_ENV"].presence
end
