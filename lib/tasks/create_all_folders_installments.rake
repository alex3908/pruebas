namespace :create_all_folders_installments do
  desc "Run create all folders installments task"
  task run: :environment do
    Folder.where(status: %w[active expired]).each do |folder|
      updated_installments = []
      quotation = folder.generate_quote
      all_installments = quotation.down_payment_monthly_payments | quotation.amr

      all_installments.each_with_index do |installment, index|
        is_down_payment = index + 1 <= quotation.down_payment_monthly_payments.length
        concept = index == 0 ? Installment::CONCEPT[:INITIAL_PAYMENT] : is_down_payment ? Installment::CONCEPT[:DOWN_PAYMENT] : Installment::CONCEPT[:FINANCING]

        persisted_installment = Installment.find_by(folder: folder, number: installment[:number], concept: concept)

        installment_attributes = {
          number: installment[:number],
          date: installment[:date],
          down_payment: installment[:down_payment].round(2),
          total: installment[:payment].round(2),
          capital: installment[:capital].present? ? installment[:capital].round(2) : nil,
          interest: installment[:interest].present? ? installment[:interest].round(2) : nil,
          debt: installment[:amount].present? ? installment[:amount] : nil,
          folder: folder,
          concept: concept
        }

        if persisted_installment.nil?
          persisted_installment = Installment.create(installment_attributes)
        else
          persisted_installment.update_attributes!(installment_attributes)
        end

        updated_installments << persisted_installment.id
      end

      folder.installments.where.not(id: updated_installments).update_all(deleted_at: Time.zone.now)
    end
  end
end