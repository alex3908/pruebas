
namespace :assign_payment_method_to_cash_backs do
  desc "adds the first payment method found with cash_back true to all cash_backs"

  task run: :environment do
    cash_back_payment_method = PaymentMethod.find_by(cash_back: true)

    count = CashBack.update_all(payment_method_id: cash_back_payment_method.id)

    puts "#{count} cash_backs asignados al método de pago #{cash_back_payment_method.name}"
  end
end
