# frozen_string_literal: true

class Api::V1::CashFlowsController < API::V1::BaseController
  include PaymentProcessorConcern, InstallmentConcern, Response

  load_and_authorize_resource :folder
  load_and_authorize_resource :cash_flow, through: :folder

  before_action :set_folder

  def create
    amount = params.dig(:cash_flow, :amount).to_f
    cash_flow = create_cash_flow(
      folder: @folder,
      client: @client,
      payment_method: @payment_method,
      bank_account: @bank_account,
      branch: @branch,
      amount: amount,
      date: @date,
      current_user: current_user
    )
    @cash_flow_id = cash_flow.id

    all_installments = set_residue(@folder)
    loop do
      raw_installment = all_installments.find { |element| element[:residue] > 0 }
      raw_installment_index = all_installments.index(raw_installment)
      installment = create_installment(folder: @folder, raw_installment: raw_installment)
      paid = raw_installment[:residue].to_f >= amount ? amount : raw_installment[:residue].to_f
      amount = amount - paid
      payment = create_payment(amount: paid, installment: installment, client: @client, branch: @branch, cash_flow: cash_flow, current_user: current_user)
      create_commissions(installment.down_payment, payment) if payment.persisted? && @stage.active_commissions && @folder.payment_scheme.is_commissionable
      @payment_id = payment.id

      all_installments[raw_installment_index][:residue] = raw_installment[:residue].to_f - paid
      break if amount <= 0
    end

    json_response(cash_flow, :created)
  rescue Exception => error
    json_error_response(error, 500)
  end

  private

    def cash_flow_params
      params.require(:cash_flow).permit(:client_id, :branch_id, :user_id, :payment_method_id, :payment_method, :bank_account_id, :clabe, :date, :amount, :status, :charge_id)
    end

    def set_folder
      @stage = @folder.stage

      if cash_flow_params[:branch_id].present?
        @branch = Branch.find_by_id(cash_flow_params[:branch_id])
      else
        @branch = @folder.user.branch
      end

      if cash_flow_params[:branch_id].present?
        @client = Client.find_by_id(cash_flow_params[:client_id])
      else
        @client = @folder.client
      end

      if cash_flow_params[:payment_method_id].present?
        @payment_method = PaymentMethod.find_by_id(cash_flow_params[:payment_method_id])
      elsif
        @payment_method = PaymentMethod.find_by_name(cash_flow_params[:payment_method])
      end

      # TODO: scope only for the accounts in the project
      if cash_flow_params[:payment_method_id].present?
        @bank_account = BankAccount.find_by_id(cash_flow_params[:bank_account_id])
      elsif
        @bank_account = BankAccount.find_by_clabe(cash_flow_params[:clabe])
      end

      if can?(:set_date, Installment) && cash_flow_params[:date].present?
        @date = cash_flow_params[:date]&.to_date
      elsif
        @date = Time.zone.now
      end

      raise(ActionController::ParameterMissing, "La sucursal elegida no fue encontrada, revisa tus parametos.") if @branch.nil?
      raise(ActionController::ParameterMissing, "El cliente elegido no fue encontrada, revisa tus parametos.") if @client.nil?
      raise(ActionController::ParameterMissing, "El método de pago elegido no es correcto, revisa tus parametos.") if @payment_method.nil?
      raise(ActionController::ParameterMissing, "La cuenta de banco elegida no fue encontrada, revisa tus parametos.") if @bank_account.nil?
    end
end
