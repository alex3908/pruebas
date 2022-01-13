# frozen_string_literal: true

namespace :set_initial_folder_users do
  desc "Run set pipeline task"

  task run: :environment do
    clients_emails = [
        ['correo_cliente','correo_usuario']
    ]
    specialist = FolderUserConcept.find_by_key(:customer_service_specialist)
    clients_emails.each do |emails|
      client_email = emails.first.try(:strip).try(:downcase)
      user_email = emails.second.try(:strip).try(:downcase)

      client = Client.find_by(email: client_email)
      user = User.find_by(email: user_email)

      puts "No se encontro el cliente #{client_email}" if client.nil?
      puts "No se encontro el usuario #{user_email}" if user.nil?

      if client.present? && user.present?
        client.folders.each do |folder|
          specialist_in_folder = folder.folder_users.where(user: user)
          unless specialist_in_folder.present?
            FolderUser.create!(user: user, role: user.role, folder: folder, percentage: 0, visible: true, folder_user_concept: specialist)
          end
        end
      end
    end
  end
end
