# frozen_string_literal: true

namespace :cash_flow do
  desc "Sets the cancellation date of the canceled cash flows"
  task set_cancellation_date: :environment do
    ActiveRecord::Base.transaction do
      cash_flows = CashFlow.canceled.where(cancellation_date: nil)
      if cash_flows.any?
        cash_flows.each do |cash_flow|
          cash_flow.update!(cancellation_date: cash_flow.updated_at)
        end
      end
    end
  end
end
