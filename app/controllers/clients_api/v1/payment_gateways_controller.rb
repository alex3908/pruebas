# frozen_string_literal: true

class ClientsApi::V1::PaymentGatewaysController < ClientsAPI::V1::BaseController
  include PaymentProcessorConcern, OnlinePaymentConcern

  before_action :set_folder
  before_action :generate
  before_action :set_online_payment_service_for_api
  before_action :set_installments
  before_action :set_description, only: [:payment, :payment_info]

  def payment_info
    @client = get_client(@folder, params[:coowner])
    coowners = @folder.clients

    address_attributes = @client.address_attributes

    missing_fields = []
    address_attributes.each do |k, v|
      if v.blank?
        missing_fields.push I18n.t("helpers.netpay_billing_attributes.#{k.to_s.underscore}")
      end
    end

    if !@next.present?
      return render json: custom_json({ message: "Sin pagos pendientes" })
    end

    if missing_fields.length > 0
      render json: custom_json({ message: "Falta información del cliente.", missing_fields: missing_fields })
    else
      render json: custom_json({ client: { id: @client.id, name: @client.label },
                                coowners: coowners.map { |coowner| { id: coowner.id, name: coowner.label } if coowner != @client }.compact,
                                description: @description,
                                total: @next[:residue].round(2) })
    end
  end


  def additional_services
    render json: @stage.additional_concepts.active
  end

  def pay_additional_service
    additional_concept = @stage.additional_concepts.active.find_by(id: params[:additional_service_id])

    unless additional_concept.present?
      return render json: custom_json({ message: I18n.t("errors.messages.not_found"), status: 404 }), status: :not_found
    end

    concept = additional_concept.name
    amount = additional_concept.amount

    client = get_client(@folder, params[:coowner])

    sku = "#{@lot_singular} #{@folder.lot.name}"

    description = "#{concept} (SKU #{sku})"

    address_attributes = client.address_attributes

    if address_attributes.any?(&:blank?) || client.main_phone.blank?

      return render json: custom_json({ message: "Faltan datos del cliente. Revise la información del cliente y vuelva a intentar." })

    else
      address_attributes[:postalCode] = address_attributes.delete(:postal_code)
      address_attributes[:street1] = address_attributes.delete(:street)
      address_attributes[:street2] = address_attributes.delete(:interior_number)
    end

    response = @online_payment_service.pay(description,
                                           payment_params[:token],
                                           amount,
                                           client,
                                           "",
                                           sku,
                                           address_attributes,
                                           payment_params[:test_email])
  ensure
    response[:message] = "Pago realizado con éxito"
    save_online_payment_ticket(response, @online_payment_service, description, concept, amount, @folder, client, nil, @project, sku)

    render json: custom_json(response)
  end

  def payment
    client = get_client(@folder, params[:coowner])

    if !@next.present?
      return render json: custom_json({ message: "Sin pagos pendientes", status: "finalized" })
    end

    amount = @next[:residue].round(2)

    sku = "#{@project.lot_entity_name} #{@folder.lot.name}"

    response = @online_payment_service.pay(@description,
                                            payment_params[:token],
                                            amount,
                                            client,
                                            new_online_payment_url(@folder.id),
                                            sku,
                                            get_address(client),
                                            payment_params[:test_email])

    if response[:status] == "success"

      notify_payment(response[:amount],
                        response[:transaction_token],
                        client,
                        @online_payment_service,
                        @folder,
                        @next,
                        @quotation,
                        @project)

    end
ensure
  response[:message] = "Pago realizado con éxito"
  save_online_payment_ticket(response, @online_payment_service, @description, @next[:concept], amount, @folder, client, nil, @project, sku)

  render json: custom_json(response)
  end

  def suscribe
  end

  def set_folder
    @folder = current_user.client.folders.where(step: Step.last_step).find_by!(id: params[:folder_id])
    @reference = @folder.id
    @lot = @folder.lot
    @stage = @lot.stage
    @phase = @stage.phase
    @project = @phase.project
    @client = @folder.client
    @enterprise = @stage.enterprise
rescue ActiveRecord::RecordNotFound
  render json: custom_json({ message: I18n.t("errors.messages.not_found"), status: 404 }), status: :not_found
  end

  def set_online_payment_service_for_api
    @online_payment_service ||= @enterprise.online_payment_services.netpay.available.first

    return render json: custom_json({ message: "Servicio no disponible" }), status: :service_unavailable unless @online_payment_service.present?
  end

  def payment_params
    params.require(:payment).permit(:token, :test_email)
  end
end
