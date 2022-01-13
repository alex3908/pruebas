namespace :settings do
  desc "TODO"
  task copy: :environment do

    Setting.find_each do |setting|
      setting.var = setting.key
      setting.save
    end
  end

end
