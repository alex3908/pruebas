# frozen_string_literal: true

# spec/support/capybara.rb
RSpec.configure do |config|
  Capybara.register_driver :headless_chrome do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    [
      "headless",
      "disable-gpu",
      "no-sandbox",
      "disable-dev-shm-usage",
      "window-size=1280x1280"
    ].each { |arg| options.add_argument(arg) }

    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end
end
