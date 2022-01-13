
namespace :assign_payment_to_installment_commission do
  desc "adds the first payment method found with cash_back true to all cash_backs"

  task run: :environment do
    Commission.all.includes(:installment).each do |commission|
      installment = commission.installment
      next if installment.payments.empty?

      created_at_upper_limit = commission.created_at + 1.minute
      created_at_lower_limit = commission.created_at - 1.minute

      payment = installment.payments.where(created_at: created_at_lower_limit..created_at_upper_limit).take

      payment = installment.payments.order(created_at: :desc).first if payment.nil?
      
      commission.payment = payment
      commission.save!
    end
  end

  task missing: :environment do
    Commission.where(payment_id: nil).includes(:installment).each do |commission|
      installment = commission.installment
     
      created_at_upper_limit = commission.created_at + 1.minute
      created_at_lower_limit = commission.created_at - 1.minute

      payment = Payment.where(installment: installment, created_at: created_at_lower_limit..created_at_upper_limit).take

      payment = Payment.where(installment: installment).order(created_at: :desc).first if payment.nil?
      
      next if payment.nil?
      commission.payment = payment
      commission.save!
    end
  end
end
