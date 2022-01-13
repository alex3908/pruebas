# frozen_string_literal: true

namespace :create_file_approvals do
  desc "Create file approvals"

  task run: :environment do
    ActiveStorage::Attachment.where(record_type: "Folder", name: ["bank_deposit", "down_payment_voucher"]).each do |file|
      folder = Folder.find_by(id: file.record_id)
      approval = folder.file_approvals.find_or_create_by!(key: file.name) if folder.public_send(file.name).attached?
      if folder.approved?
        approval.status = "approved"
        approval.approved_by_id = 1
        approval.save!
      end
    end
  end
end
  