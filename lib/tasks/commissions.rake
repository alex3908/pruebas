namespace :commissions do
  desc "Generates commission of all the folders"
  task base: :environment do
    folders = Folder.all
    folders.each do |folder|
      if folder.folder_users.empty?
        folder.set_folder_users

        if folder.step.is_last_one?
          quotation = folder.generate_quote
          folder.folder_users.each do |commission|
            amount = quotation.total_with_discount * (commission.percentage / 100)
            commission.update(amount: amount.round(2))
          end
        end
      else
        folder.folder_users.each do |folder_user|
          attributes = Hash.new

          if folder_user.concept == "Por referido"
            attributes[:concept] = FolderUser::CONCEPT[:REFERRED]
          elsif folder_user.concept == "Por venta"
            attributes[:concept] = FolderUser::CONCEPT[:SALE]
          elsif folder_user.concept == "Por seguimiento"
            attributes[:concept] = FolderUser::CONCEPT[:FOLLOW_UP]
          end

          if folder_user.folder.step.is_last_one?
            quotation = folder_user.folder.generate_quote
            amount = quotation.total_with_discount * (folder_user.percentage / 100)
            attributes[:amount] = amount.round(2)
          end

          attributes[:role_id] = folder_user.user.role_id

          folder_user.update!(attributes)
        end
      end
    end
  end

  desc "Generates the ammount of commission of all the folders"
  task amount: :environment do

    folders =  Folder.includes(:payment_scheme, documents: [:document_template], lot: { stage: { phase: :project } }).joins(:step).where("steps.name" => "Finalizado")
    folders.map do |folder|
      folder_users = folder.folder_users
      quotation = folder.generate_quote
      amr = quotation.down_payment_monthly_payments | quotation.amr
      installments = folder.installments

      next if (quotation.down_payment_total / quotation.total_price) < 0.1

      amr.each_with_index do |installment, index|
        is_down_payment = index + 1 <= quotation.down_payment_monthly_payments.length

        if index == 0
          concept = Installment::CONCEPT[:INITIAL_PAYMENT]
        elsif is_down_payment
          concept = Installment::CONCEPT[:DOWN_PAYMENT]
        else
          concept = Installment::CONCEPT[:FINANCING]
        end

        current_installment = installments.find { |element| (element.number.to_i == installment[:number] || element.number == "A") && element.concept == concept }
        total_amount = installment[:payment].round(2)

        if current_installment.present? && current_installment.total_paid >= total_amount && installment[:down_payment] > 0
          next if current_installment.commissions.any?

          payment_percentage = installment[:down_payment] / quotation.down_payment_total
          folder_users.each do |folder_user|
            amount = folder_user.amount * payment_percentage

            if amount > 0
              if current_installment.payments.last.present?
                date = current_installment.payments.last.cash_flow.date
              else
                date = Time.zone.now.strftime("%Y-%m-%d")
              end

              commission = Commission.new(
                  installment: current_installment,
                  folder_user: folder_user,
                  amount: amount.round(2),
                  date: date,
                  status: Commission::STATUS[:PENDING]
              )

              commission.save
            end
          end
        end
      end
    end
  end

  desc "It generates the commissions of the folders where the maximum amount of commission is greater than 0."
  task generate: :environment do
    include PaymentProcessorConcern

    installments = Installment.joins(folder: :payment_scheme)
                              .where(folders: { status: :active, step: Step.last_step })
                              .where("payment_schemes.max_commission_amount > ?", 0)


    installments.each do |installment|
      next unless installment.is_paid?

      payment = installment.payments.last

      next if payment.nil?

      @quotation = installment.folder.generate_quote
      create_commissions(installment.down_payment, payment)
    end
  end

  desc "Update the max commission amount in payment schemes"
  task add_max_commission_amount_to_payment_schemes: :environment do
    include QuotationHandler
    ActiveRecord::Base.transaction do
      Folder.all.each do |folder|
        quotation = folder.generate_quote

        next unless quotation.down_payment_percentage.to_i < 10

        folder.payment_scheme.assign_attributes(
          max_commission_amount: set_max_commission_amount(folder.payment_scheme.total_payments.to_f, folder.lot.stage.max_commission_amount)
        )

        folder.lot.with_lock do
          folder.save!
        end
      end
    end
  end
end
