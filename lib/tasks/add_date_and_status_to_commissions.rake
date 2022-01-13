
namespace :add_date_to_commissions do
  desc "add date and status to commissions"

  task run: :environment do
    Commission.where(date: nil).each do |commission|
      if commission.installment.payments.last.present?
        date = commission.installment.payments.last.cash_flow.date
      else
        date = commission.created_at.strftime("%Y-%m-%d")
      end

      commission.update(date: date)
    end
  end
end