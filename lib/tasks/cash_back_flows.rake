# frozen_string_literal: true

namespace :cash_back_flow do
  desc "Assign cash back and cash flows to new cash back flow objects"

  task assign_folder_id: :environment do
    cash_backs = CashBack.all
    cash_backs.each do |cash_back|
      folders = cash_back.client.folders
      if folders.size == 1
        cash_back.update(exclusive_folder_id: folders.first.id)
      else
        puts "No se limitó la bonificación #{cash_back.id}"
      end
    end
  end

  task assign_cash_back_flows: :environment do
    clients = Client.all
    clients.each do |client|
      cash_flows = CashFlow.where(cash_back: true, client: client).order(:created_at)
      cash_backs = CashBack.where(client: client).order(:created_at)

      cash_flows.each do |flow|
        cash_backs.each do |cashback|
          next if cashback.amount == 0
          break if flow.amount <= 0

          residue = cashback.amount - flow.amount
          flow.amount = flow.amount - cashback.amount
          balance_left = residue <= 0 ? 0 : residue.abs

          CashBackFlow.create_with(
            amount_used: cashback.amount - balance_left,
            balance_after: balance_left
          ).find_or_create_by(
            cash_back_id: cashback.id, 
            cash_flow_id: flow.id,
          )

          cashback.amount = balance_left
        end
      end
    end
  end
end
