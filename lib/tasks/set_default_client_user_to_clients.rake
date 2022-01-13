# frozen_string_literal: true

namespace :set_default_client_user_to_clients do
    desc "Set default client user to client"
  
    task run: :environment do
        client_user_concept = ClientUserConcept.find_or_create_by(name: "Ejecutivo de ventas", key: :sales_executive, max_users: 1)
        Client.all.each do |client|
            client.client_users.create(user: client.user, client_user_concept: client_user_concept)
        end
    end
  end
  