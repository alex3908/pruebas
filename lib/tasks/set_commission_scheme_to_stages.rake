namespace :set_commission_scheme_to_stages do
  desc "created commission scheme and assign it to all stages that don't have one"

  task run: :environment do
    initial_commission_scheme = CommissionScheme.find_or_create_by(name: "Global", global_commission: 0)

    Stage.where(commission_scheme: nil).each do |stage|
      stage.update(commission_scheme: initial_commission_scheme)
    end
  end
end
