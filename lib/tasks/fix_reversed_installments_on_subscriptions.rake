# frozen_string_literal: true

namespace :fix_reversed_installments_on_subscriptions do
  desc "Fix subscriptions that have wrong order of the installments in SubscriptionPlans"

  task run: :environment do
    subs_updated = []
    Subscription.joins(:subscription_plans).each do |sub|
      first_financing_plan = sub.subscription_plans.financing.first
      second_financing_plan = sub.subscription_plans.financing.second
      
      if second_financing_plan.present? && first_financing_plan.start_date > second_financing_plan.start_date
        ActiveRecord::Base.transaction do
          sub.subscription_plans.destroy_all
          folder = sub.folder

          down_payment_plans = folder.down_payment_installment_updates.map { |installments| build_subscription_plan(installments) }
          financing_plans = folder.financing_installment_updates.map { |installments| build_subscription_plan(installments) }

          plans = [
            build_subscription_plan(folder.installments.initial_payment),
            *down_payment_plans,
            *financing_plans
          ].compact

          sub.subscription_plans = plans
          sub.update_netpay_plan
          sub.save!
          subs_updated << sub
        end
      end
    end

    folders_updated = subs_updated.map { |s| s.folder.id }
    puts "Se actualizaron #{subs_updated.size} subscriptiones"
    puts "Expedientes que actualizaron su suscripción: #{folders_updated.join(", ")}"
  end

  def build_subscription_plan(unsorted_installments)
    installments = unsorted_installments.sort_by(&:date)
    installments_count = installments.count(&:is_unpaid?)
    return nil if installments_count == 0

    SubscriptionPlan.new(
      amount: installments.first.total,
      payments_count: installments.count(&:is_unpaid?),
      start_date: installments.first.date,
      end_date: installments.last.date,
      concept_description: installments.first.concept
    )
  end
end
