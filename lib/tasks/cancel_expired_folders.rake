namespace :cancel_expired_folders do
  desc "Run cancel expired folders task"
  task run: :environment do
    now = Time.zone.now.to_date
    Folder.where(status: Folder::STATUS[:EXPIRED]).each do |folder|
      expired_lifetime = Setting.find_by_key("expired_lifetime").value.to_i
      unless ((now.prev_day(expired_lifetime))..(now)).include?(folder.expiration_date.to_date)
        folder.update(status: Folder::STATUS[:CANCELED])
      end
    end
  end
end