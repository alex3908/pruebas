# frozen_string_literal: true

namespace :fill_lock_payment do
  desc "Run fill_lock_payment task"

  task run: :environment do
    folders = Folder.all.includes(:payment_scheme)
    folders.each do |folder|
      folder.payment_scheme.update(lock_payment: folder.payment_scheme.initial_payment)
    end
  end
end
  