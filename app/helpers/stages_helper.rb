# frozen_string_literal: true

module StagesHelper
  include ApplicationHelper
  def corrections(stage, file)
    corrections_array = import_excel(file)

    ActiveRecord::Base.transaction do
      corrections_array.each do |correction|
        lot_name = correction["Lote"].to_s
        lot = Lot.find_by(stage: stage, name: lot_name.to_s)
        folder = Folder.find_by(lot_id: lot.id, step: Step.last_step)

        if folder.present? && folder.status != Folder::STATUS[:CANCELED] || folder.status != Folder::STATUS[:EXPIRED]
          payment_scheme = folder.payment_scheme
          payment_scheme.update!(down_payment: correction["Saldo de enganche"]) if correction["Saldo de enganche"].present?
          payment_scheme.update!(initial_payment: correction["Apartado"]) if correction["Apartado"].present?
          payment_scheme.update!(total_payments: correction["Plazo del financiamiento"]) if correction["Plazo del financiamiento"].present?
          payment_scheme.update!(down_payment_finance: correction["Plazo del enganche"]) if correction["Plazo del enganche"].present?
          payment_scheme.update!(buy_price: correction["Precio por m2"]) if correction["Precio por m2"].present?
          payment_scheme.update!(discount: correction["Descuento"]) if correction["Descuento"].present?
          if correction["Diferido"].present? && correction["Diferido"] == "Si"
            payment_scheme.update!(start_installments: correction["Meses de gracia"]) if correction["Meses de gracia"].present?
          else
            payment_scheme.update!(start_installments: nil)
          end
          payment_scheme.update!(zero_rate: correction["Meses sin intereses"]) if correction["Meses sin intereses"].present?
        end
      end
    end
  end

  def initial_charges(stage, file)
    charges_array = import_excel(file)

    ActiveRecord::Base.transaction do
      charges_array.each do |charge|
        lot = Lot.find_by(stage: stage, name: charge["Lote"])
        folder = Folder.find_by(lot_id: lot.id, step: Step.last_step)

        if folder.present?
          installment = Installment.find_by(folder: folder, number: charge["Número de pago"], concept: charge["Concepto de pago"])
          if installment.nil?
            installment = Installment.new
            installment.folder = folder
            installment.number = charge["Número de pago"]
            installment.concept = charge["Concepto de pago"]
            installment.save!
          end

          payment_method = PaymentMethod.find_by("LOWER(name) LIKE LOWER(?)", "%#{charge["Forma de pago"]}%")
          user = User.find_by("LOWER(email) LIKE LOWER(?)", "%#{charge["Personal"]}%")
          branch = Branch.find_by(name: charge["Sucursal"])

          payment = Payment.new
          payment.installment = installment
          payment.date = charge["Fecha de pago"]
          payment.amount = charge["Cantidad"]
          payment.payment_method = payment_method
          payment.user = user
          payment.client = folder.client
          payment.branch_id = branch.nil? ? folder.user.branch_id : branch.id
          payment.bank_account = BankAccount.find_by(clabe: charge["Especificación de pago"].tr(" ", ""))
          payment.save!
        end
      end
    end
  end

  def user_has_stage_access?(stages, stage)
    can?(:reserve, :quote) && stages.include?(stage) && stage.active?
  end

  def enable_stage_button_availibility?(stage)
    stage.slug.present? && stage.phase.slug.present? && stage.project.slug.present?
  end

  def message_miss_stage_slug_for_url(stage)
    message = "Falta el dato de slug en"
    message += " #{Project.model_name.human}" unless stage.project.slug.present?
    message += " #{Phase.model_name.human}" unless stage.phase.slug.present?
    message += " #{Stage.model_name.human}" unless stage.slug.present?
    message
  end
end
