# frozen_string_literal: true

namespace :update_subscription_amounts_on_netpay do
  desc "Task that checks and updates the plan amount on Netpay"

  task run: :environment do
    subs_updated = []
    Subscription.joins(:subscription_plans).currently_active.each do |sub|
      service = sub.online_payment_service.suscription_manager
      current_plan = sub.active_subscription_plan
      online_subscription = service.get_subscription(sub.subscription_id)

      if current_plan.present? && current_plan["amount"] != online_subscription["amount"]
        service.update_subscription_amount(sub.subscription_id, current_plan.amount)
        subs_updated << sub
      else
        next
      end
    end

    subs_updated = subs_updated.map { |s| s.folder.id }
    puts "Se actualizaron #{subs_updated.size} subscripciones"
  rescue RestClient::Exception => ex
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { request: JSON.parse(ex.response.request.args[:payload]), response: JSON.parse(ex.response) }) if ex.respond_to?(:response)
    end
  rescue StandardError => ex
    Bugsnag.notify(ex) do |report|
      report.add_tab(:netpay_api_response, { message: ex.message })
    end
  end
end
