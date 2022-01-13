# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.6"

# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "~> 5.2.5"
# Use postgresql as the database for Active Record
gem "pg", ">= 0.18", "< 2.0"
# Use Puma as the app server
gem "puma", "~> 3.11"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "mini_racer", platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.2"
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem "turbolinks", "~> 5"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.5"
# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"
# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use ActiveStorage variant
gem "mini_magick"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false

gem "rswag"
gem "rswag-api"
gem "rswag-ui"
gem "pdf-reader"
gem "httparty"


group :development, :test do
  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "factory_bot_rails"
  gem "faker"
  gem "timecop", "~> 0.9.2"
  gem "rubocop", "~> 0.81.0", require: false
  # gem "pronto-erb_lint", "~> 0.1.5"
  gem "erb_lint", require: false
  gem "dotenv-rails"
  gem "webdrivers", "~> 4.6"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :development do
  # Access an interactive console on exception pages or by calling "console" anywhere in the code.
  gem "web-console", ">= 3.3.0"
  gem "listen", ">= 3.0.5", "< 3.2"
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "spring-commands-rspec"

  gem "better_errors"
  gem "binding_of_caller"
  gem "squasher"
  gem "letter_opener"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
  gem "shoulda-matchers", "~> 4.0"
  gem "pronto"
  gem "pronto-rubocop", require: false
end

gem "devise"
gem "devise-jwt"
gem "active_model_serializers", "~> 0.10.0"
gem "seed_dump"
gem "knock"
gem "bcrypt", "~> 3.1.7"
gem "jwt"
gem "rack-cors", require: "rack/cors"
gem "font-awesome-rails"
gem "cancancan", "~> 2.0"
gem "will_paginate", "~> 3.3.0"
gem "pdfkit"
gem "wicked_pdf", "~> 2.0", ">= 2.0.2"
gem "wkhtmltopdf-binary", "~> 0.12.5.4"
gem "numbers_and_words"
gem "rails_12factor", group: :production
gem "bugsnag", "~> 6.11"
gem "activesupport"
gem "paypal-sdk-rest"
gem "aws-sdk-s3", require: false
gem "mailgun-ruby"
gem "time_difference"
gem "pretender"
gem "hubspot-ruby"
gem "ruby-limiter", "~> 2.1"
gem "roo"
gem "devise_invitable", "~> 2.0.0"
gem "nokogiri", "~> 1.6", ">= 1.6.8"
gem "rubyzip", ">= 1.2.1"
gem "countries", require: "countries/global"
gem "bootstrap-datepicker-rails", "~> 1.9", ">= 1.9.0.1"
gem "railties", ">= 5.2.4.2"
gem "select2-rails", "~> 4.0", ">= 4.0.3"
gem "jquery-rails"
gem "jquery-ui-rails"
gem "rails_sortable"
gem "popper_js", "~> 1.14.5"
gem "openpay"
gem "htmltoword", "~> 1.1"
gem "ancestry"
gem "dotiw"
gem "combine_pdf"
gem "bullet", "~> 6.1"
gem "scout_apm", "~> 2.6"
gem "delayed_job_active_record", "~> 4.1"
gem "caxlsx_rails", "~> 0.6.2"
gem "caxlsx", "~> 3.1"
gem "liquid", "~> 4.0"
gem "webpacker", "~> 4.x"
gem "acts_as_paranoid", "~> 0.7.0"
gem "paper_trail"
gem "paper_trail-globalid"
gem "chartkick"
gem "twilio-ruby", "~> 5.40"
gem "textris", "~> 0.7.1"
gem "bitly"
gem "savon", "~> 2.12.0"
gem "sequenced"
gem "activejob-cancel", "~> 0.3.1"
gem "rspec-rails"
gem "js-routes"
gem "ransack"
gem "active_storage_validations"
gem "rails-settings-cached", "~> 2.7"
gem "postmark", "~> 1.22"
gem "postmark-rails", "~> 0.21.0"
gem "cocoon", "~> 1.2"

gem "azure-storage-blob", "~> 2.0"
