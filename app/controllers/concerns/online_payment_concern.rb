# frozen_string_literal: true

module OnlinePaymentConcern
  def get_address(client)
    address_attributes = client.address_attributes
    .except(:street, :postal_code, :interior_number)

    address_attributes[:postalCode] = client.postal_code.gsub(/[^.0-9]+/, "")
    address_attributes[:street1] = I18n.transliterate(client.street)
    address_attributes[:street2] = I18n.transliterate(client.interior_number)
    address_attributes
  end

  def generate
    @quotation = @folder.generate_quote
  end

  def set_installments
    @overdue = false
    (@quotation.down_payment_monthly_payments + @quotation.amr).each do |installment|
      actual = @folder.installments.find { |element| element.number == installment[:number].to_s && element.concept == installment[:concept] }
      if actual.present?
        concept = actual.concept
        total_paid = actual.total_paid
        if total_paid < installment[:payment].round(2)
          @overdue = true if installment[:date].strftime("%Y/%m/%d") < Time.zone.now.strftime("%Y/%m/%d")
          @next = set_next_installment(installment, concept, installment[:payment].round(2) - total_paid) if @next.nil?
          @next_subscription = set_next_installment(installment, concept, installment[:payment].round(2) - total_paid) if @next_subscription.nil? && (installment[:concept] == Installment::CONCEPT[:FINANCING] || installment[:concept] == Installment::CONCEPT[:LAST_PAYMENT])
        end
      else
        concept = installment[:capital].present? ? (installment[:concept] == Installment::CONCEPT[:LAST_PAYMENT] ? Installment::CONCEPT[:LAST_PAYMENT] : Installment::CONCEPT[:FINANCING]) : Installment::CONCEPT[:DOWN_PAYMENT]
        @overdue = true if installment[:date].strftime("%Y/%m/%d") < Time.zone.now.strftime("%Y/%m/%d")
        @next = set_next_installment(installment, concept, installment[:payment].round(2)) if @next.nil?
        @next_subscription = set_next_installment(installment, concept, installment[:payment].round(2) - total_paid) if @next_subscription.nil? && (installment[:concept] == Installment::CONCEPT[:FINANCING] || installment[:concept] == Installment::CONCEPT[:LAST_PAYMENT])
      end
    end
  end

  def set_next_installment(installment, concept, residue)
    installment[:concept] = concept
    installment[:residue] = residue
    installment
  end

  def get_description(next_installment, lot_singular, lot, stage_singular, stage, phase_singular, phase, project_singular, project)
    concept = next_installment[:concept]
    if concept == Installment::CONCEPT[:FINANCING]
      concept_message = "Cargo de mensualidad (#{next_installment[:number]})"
    elsif concept == Installment::CONCEPT[:INITIAL_PAYMENT]
      concept_message = "Pago de apartado"
    elsif concept == Installment::CONCEPT[:DOWN_PAYMENT]
      concept_message = "Cargo del enganche (#{next_installment[:number]})"
    elsif concept == Installment::CONCEPT[:LAST_PAYMENT]
      concept_message = "Cargo de contra entrega (#{next_installment[:number]})"
    end

    "#{concept_message} del #{lot_singular} #{lot.name} de la #{stage_singular} #{stage.name} de la #{phase_singular} #{phase.name} del #{project_singular} #{project.name}"
  end

  def notify_payment(amount, transaction_token, client, online_payment_service, folder, next_installment, quotation, project)
    branch = online_payment_service.branch.present? ? online_payment_service.branch : folder.user.branch
    installment = create_installment(folder: folder, raw_installment: next_installment)
    cash_flow = create_cash_flow(folder: folder, client: client, branch: branch, amount: amount, date: Time.zone.now, charge_id: transaction_token, bank_account: online_payment_service.bank_account, payment_method: online_payment_service.payment_method)
    payment = create_payment(amount: amount, installment: installment, client: client, branch: branch, cash_flow: cash_flow)
    create_commissions(installment.down_payment, payment) if payment.persisted? && folder.stage.active_commissions && folder.payment_scheme.is_commissionable
    branches = Branch.where(active: true)
    NotifyPaymentJob.perform_later(folder, payment, quotation.as_json, branches.to_a, project)
  end

  def set_description
    @description = get_description(@next, @lot_singular, @lot, @stage_singular, @stage, @phase_singular, @phase, @project_singular, @project)
  end

  def save_online_payment_ticket(response, online_payment_service, description, concept_key, amount, folder, client, session, project, sku)
    status = response&.fetch("status", :error) || :error
    error = response&.fetch("error", nil)
    OnlinePaymentTicket.create!(
      online_payment_service_id: online_payment_service.id,
      concept: description,
      concept_key: concept_key,
      amount: amount,
      folder_id: folder.id,
      client_id: client.id,
      token: session.fetch(:np_transaction, nil),
      status: status,
      message: error,
      sku: sku,
      response: response
    )
  end

  def get_client(folder, coowner)
    client = folder.client
    if folder.clients.length > 1 && coowner.present?
      client = folder.clients.find { |cr| cr.id == coowner.to_i }
    end
    client
  end

  def save_suscription(folder, client, netpay_subscriptions, is_update, next_subscription, project_singular, phase_singular, stage_singular)
    attributes = {
      concept_key: "finance",
      folder: folder,
      client: client,
      subscription_id: netpay_subscriptions["id"],
      status: netpay_subscriptions["status"],
      exp_year: netpay_subscriptions["cardToken"]["expYear"],
      exp_month: netpay_subscriptions["cardToken"]["expMonth"],
      last_four_digits: netpay_subscriptions["cardToken"]["lastFourDigits"],
      last_update: netpay_subscriptions["createdAt"],
      billing_start: netpay_subscriptions["billingStart"],
      billing_end: netpay_subscriptions["billingEnd"],
      online_payment_service_id: folder.stage.enterprise.available_netpay_service.id
  }

    if folder.subscription.nil?
      Subscription.find_or_create_by(attributes)
    else
      folder.subscription.update_attributes(attributes)
    end

    if is_update
      SubscriptionMailer.confirm_update_subscription(client.email, client, folder, next_subscription[:date].strftime("%d"), project_singular, phase_singular, stage_singular).deliver_later
    else
      SubscriptionMailer.confirm_subscription(client.email, client, folder, next_subscription[:date].strftime("%d"), project_singular, phase_singular, stage_singular).deliver_later
    end
  end
end
