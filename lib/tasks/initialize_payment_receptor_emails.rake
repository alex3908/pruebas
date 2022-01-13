namespace :initialize_payment_receptor_emails do
  desc "Move Stage :payment_email to :payment_receptor_emails"

  task run: :environment do
    Stage.all.each do |stage|
      next unless stage.payment_receptor_emails.blank?

      email = stage.payment_email

      stage.update_attributes(payment_receptor_emails: [email])
    end
  end
end
