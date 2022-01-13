# frozen_string_literal: true

class Webhook::OnlinePaymentTicketsController < Webhook::BaseController
  include PaymentProcessorConcern

  def create
    if OnlinePaymentService.providers.fetch(params[:provider], nil) == "STP"
      clabe_params = parse_stp_clabe_data

      stage = Stage.find(clabe_params[:stage_id])
      online_payment_service = stage.enterprise.online_payment_services.stp.take

      return json_error_response("Enterprise stp code is different from the code in CLABE", :unprocessable_entity) if invalid_clabe?(online_payment_service.stp_service)

      folder = Folder.find(clabe_params[:folder_id])
      amount = stp_params["monto"].to_f
      cash_flow = create_cash_flow(
        folder: folder,
        client: folder.client,
        payment_method: online_payment_service.payment_method,
        bank_account: online_payment_service.bank_account,
        amount: stp_params["monto"],
        charge_id: stp_params["id"]
      )

      all_installments = set_residue(folder)

      loop do
        raw_installment = all_installments.find { |element| element[:residue] > 0 }
        break if raw_installment.nil?
        raw_installment_index = all_installments.index(raw_installment)

        installment = create_installment(folder: folder, raw_installment: raw_installment)

        if raw_installment[:residue].to_f >= amount || Restructure.down_payment_concept?(params[:restructure_type]) || Restructure.financing_concept?(params[:restructure_type])
          paid = amount
        else
          paid = raw_installment[:residue].to_f
        end

        amount = amount - paid
        create_payment(
          amount: paid.round(2),
          installment: installment,
          client: folder.client,
          cash_flow: cash_flow
        )

        all_installments[raw_installment_index][:residue] = raw_installment[:residue].to_f - paid
        break if amount <= 0
      end
    end
  end

  def stp_params
    params.require(:abono).permit(
      "id",
      "fechaOperacion",
      "institucionOrdenante",
      "institucionBeneficiaria",
      "claveRastreo",
      "monto",
      "nombreOrdenante",
      "tipoCuentaOrdenante",
      "cuentaOrdenante",
      "rfcCurpOrdenante",
      "nombreBeneficiario",
      "tipoCuentaBeneficiario",
      "cuentaBeneficiario",
      "rfcCurpBeneficiario",
      "conceptoPago",
      "referenciaNumerica",
      "empresa"
    )
  end

  private

    def invalid_clabe?(service)
      clabe = stp_params["cuentaBeneficiario"]
      clabe_data = parse_stp_clabe_data

      clabe_data[:key_code] != service.properties["key_code"] && clabe != service.generate_clabe_for_client(clabe_data[:folder_id])
    end

    def parse_stp_clabe_data
      clabe = stp_params["cuentaBeneficiario"]

      {
        key_code: clabe[6..9],
        stage_id: clabe[10..12],
        folder_id: clabe[13..16],
      }
    end
end
