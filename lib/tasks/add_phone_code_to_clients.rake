# frozen_string_literal: true

namespace :add_phone_code_to_clients do
  desc "add phone code to clients"

  task run: :environment do
    clients = Client.all
    clients.each do |client|
      client.update(main_phone: client.main_phone.insert(0, '+52')) if client.main_phone.present?
      client.update(optional_phone: client.optional_phone.insert(0, '+52')) if client.optional_phone.present?
    end
  end
end
  