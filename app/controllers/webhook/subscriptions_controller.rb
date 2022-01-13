# frozen_string_literal: true

class Webhook::SubscriptionsController < Webhook::BaseController
  include PaymentProcessorConcern, EntityNamesConcern
  helper_method :wicked_blob_path

  def create
    if params[:data].present? && params.dig(:data, :id).present?
      @subscription = Subscription.find_by(subscription_id: params.dig(:data, :id))
      if @subscription.present?
        folder = @subscription.folder
        amount = params.dig(:data, :amount).to_f
        transaction_token = params.dig(:data, :transactionTokenId)
        plan = @subscription.active_subscription_plan
        @payments = []

        if plan.blank? && params.dig(:data, :object) == "Paid"
          quotation = folder.generate_quote
          @quotation = quotation

          if @subscription.concept_key == "balance_down_payment"
            next_payment = set_down_payment_installments(folder)
          else
            next_payment = old_set_installments(folder)
          end

          service = get_netpay_service(folder)
          branch = service.branch.present? ? service.branch : folder.user.branch
          @cash_flow = create_cash_flow(folder: folder, client: @subscription.client, branch: branch, amount: amount, charge_id: transaction_token, bank_account: service.bank_account, payment_method: service.payment_method)

          @payments << new_payment(service, @subscription.client, folder, next_payment, amount, transaction_token, @cash_flow)

          # render invoice
          @name = "COMPROBANTE DE PAGO"
          @branches = Branch.where(active: true)
          @project = folder.project
          send_email_notifications(@cash_flow.to_file.render_to_string, folder, @payments, @subscription, params.dig(:data, :amount).to_f)

          json_response(@payments, :created)
        elsif plan.present? && params.dig(:data, :object) == "Paid"
          quotation = folder.generate_quote
          service = @subscription.online_payment_service
          @quotation = quotation

          ActiveRecord::Base.transaction do
            @cash_flow = create_cash_flow(folder: folder, client: @subscription.client, branch: folder.user.branch, amount: amount, charge_id: transaction_token, bank_account: service.bank_account, payment_method: service.payment_method)

            loop do
              break if amount <= 0

              next_payment = set_installments(folder.reload)

              if (amount - next_payment.residue) <= 0
                payment_amount = amount
              else
                payment_amount = next_payment.residue.round(2)
              end

              @payments << new_payment(service, @subscription.client, folder, next_payment, payment_amount, transaction_token, @cash_flow)

              amount = amount - next_payment.residue.round(2)
            end
          end

          # render invoice
          @name = "COMPROBANTE DE PAGO"
          @branches = Branch.where(active: true)
          @project = folder.project
          send_email_notifications(@cash_flow.to_file.render_to_string, folder, @payments, @subscription, params.dig(:data, :amount).to_f)

          json_response(@payments, :created)
        else
          if folder.stage.payment_receptor_emails.present?
            folder.stage.payment_receptor_emails.each do |email|
              SubscriptionMailer.subscription_payment_error(email, folder.client, folder, amount).deliver_later
            end
          end

          SubscriptionMailer.payment_error(@subscription.client, folder).deliver_later

          OnlinePaymentTicket.create(
            concept_key: "subscription",
            sku: "#{@lot_singular} #{folder.lot.name}",
            amount: amount,
            token: transaction_token,
            status: "failed",
            client: @subscription.client,
            folder: folder,
            online_payment_service: @subscription.online_payment_service,
            response: params,
            webhook: true
          )

          json_error_response("PaymentFailed", :unprocessable_entity)
        end
      else
        json_error_response("Subscription not found with id: '#{params.dig(:data, :id)}'", :not_found)
      end
    else
      json_error_response("Bad Request", 400)
    end
  rescue Exception => ex
    OnlinePaymentTicket.create(
      concept_key: "subscription",
      sku: "#{@lot_singular} #{folder.lot.name}",
      amount: amount,
      token: transaction_token,
      status: "error",
      client: @subscription.client,
      folder: folder,
      online_payment_service: @subscription.online_payment_service,
      response: params,
      webhook: true
    )

    slack_webhook = Setting.find_by(key: "slack_subscription_notifs_hook").try(:convert)
    if slack_webhook.present?
      message = "Excepción en webhook de Suscripciones \n"
      message = message + "#{ex.full_message}\n"
      message = message + "ID local de suscripción: #{@subscription.id}\n" if @subscription.present?
      message = message + "Parámetros: #{params.as_json}"

      SendSlackNotificationJob.perform_later(message, slack_webhook)
    end

    raise ex
  end

  private

    def set_installments(folder)
      next_payment = nil
      folder.persisted_installments.each do |installment|
        total_paid = installment.total_paid
        if total_paid < installment.total.round(2)
          installment.residue = installment.total.round(2) - total_paid
          next_payment = installment
          break
        end
      end

      next_payment
    end

    def old_set_installments(folder)
      next_payment = nil
      folder.persisted_installments.each do |installment|
        next if installment.concept != Installment::CONCEPT[:FINANCING]
        next_payment = installment if next_payment.nil? && !installment.is_paid?
        break if next_payment.present?
      end
      next_payment
    end

    def set_down_payment_installments(folder)
      next_payment = nil
      folder.persisted_installments.each do |installment|
        next if installment.number == "A" || installment.down_payment <= 0
        next_payment = installment if next_payment.nil? && !installment.is_paid?
        break if next_payment.present?
      end
      next_payment
    end

    def new_payment(service, client, folder, next_payment, amount, token_id, cash_flow)
      plan = @subscription.reload.active_subscription_plan

      installment = next_payment

      payment = create_payment(amount: amount, cash_flow: cash_flow, branch: folder.user.branch, installment: installment, client: client)

      create_ticket(folder, plan.present? ? plan.concept_description : @subscription.concept_key, amount, token_id, client, @subscription)

      create_commissions(installment.down_payment, payment) if payment.persisted? && folder.stage.active_commissions && folder.payment_scheme.is_commissionable
      payment
    end

    def send_email_notifications(payment_pdf, folder, payments, subscription, amount)
      project = folder.lot.project
      SubscriptionMailer.confirm_subscription_payment(subscription.client.email, payment_pdf, subscription.client, subscription, amount, project.project_entity_name, project.phase_entity_name, project.stage_entity_name).deliver_later
      if folder.stage.payment_receptor_emails.present?
        folder.stage.payment_receptor_emails.each do |email|
          payments.each do |payment|
            PaymentMailer.notify_payment_to_stakeholders(email, payment_pdf, folder.client, payment, project.project_entity_name, project.phase_entity_name, project.stage_entity_name).deliver_later
          end
        end
      end
    end

    def get_netpay_service(folder)
      if @subscription.online_payment_service
        @subscription.online_payment_service
      else
        folder.stage.enterprise.online_payment_services.netpay.take
      end
    end

    def create_ticket(folder, concept, amount, token_id, client, subscription)
      @folder = folder
      set_project_entity_names_by_folder

      OnlinePaymentTicket.create(
        concept_key: concept,
        sku: "#{@lot_singular} #{folder.lot.name}",
        amount: amount,
        token: token_id,
        status: "success",
        client: client,
        folder: folder,
        online_payment_service: subscription.online_payment_service,
        response: params,
        webhook: true
      )
    end
end
