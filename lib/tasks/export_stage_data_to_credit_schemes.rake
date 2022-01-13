
namespace :export_stage_data_to_credit_schemes do
    desc "add date and status to commissions"
  
    task run: :environment do
      ActiveRecord::Base.transaction do
        Stage.all.each do |stage|
          credit_scheme_old = stage.credit_scheme
          credit_scheme = CreditScheme.new(name: stage.full_path(" / "),
            status: credit_scheme_old.status,
            compound_interest: credit_scheme_old.compound_interest,
            first_payment: stage.first_payment,
            lock_payment: stage.lock_payment,
            initial_payment: stage.initial_payment,
            min_capital_payment: stage.min_capital_payment,
            min_down_payment_advance: stage.min_down_payment_advance,
            max_grace_months: stage.max_grace_months,
            max_delay_payments: stage.max_delay_payments,
            show_rate: stage.show_rate,
            show_price: stage.show_price,
            relative_discount: stage.relative_discount,
            immediate_extra_months: stage.immediate_extra_months,
            max_percent_immediate_lots_sold: stage.max_percent_immediate_lots_sold,
            min_down_payment: stage.min_down_payment,
            max_finance: stage.max_finance,
            start_installments: stage.start_installments,
            copy: true)
          
          if credit_scheme.save
            stage.payment_plans.each do |payment_plan|
              credit_scheme.payment_plans.create(name: payment_plan.name,
                                                 discount: payment_plan.discount, 
                                                 total_payments: payment_plan.total_payments)
            end

            credit_scheme_old.periods.each do |period|
              credit_scheme.periods.create(payments: period.payments,
                                           interest: period.interest,
                                           order: period.order)
            end
            stage.update_attributes(credit_scheme: credit_scheme)
          end
      
          credit_scheme_old.payment_schemes.update_all(credit_scheme_id: credit_scheme.id)
        end
        
        CreditScheme.all.each do |credit_scheme|
          credit_scheme.destroy unless Stage.exists?(credit_scheme_id: credit_scheme.id) || PaymentScheme.exists?(credit_scheme_id: credit_scheme.id) 
        end
      end

    end
end