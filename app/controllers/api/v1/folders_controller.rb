# frozen_string_literal: true

class Api::V1::FoldersController < API::V1::BaseController
  include QuotationsHelper
  include OverdueBalanceReportJobHandler
  include FolderHandler, FoldersHelper
  load_and_authorize_resource :folder
  before_action :set_folder, only: [:cancel]
  before_action :evo, only: [:balances_close_to_due, :folder_balances_close_to_due, :folders_information, :folder_information]
  helper_method :sort_column, :sort_direction

  def index
    @folders = @folders.search(params).paginate(page: params[:page], per_page: @per_page)
  end

  def cancel
    raise CanCan::AccessDenied.new("No tiene permisos para cancelar este expediente") unless @can_cancel_folder
    @folder.update(status: Folder::STATUS[:CANCELED])
    @folder.lot.status = Lot::STATUS[:FOR_SALE]
    @folder.lot.save
  rescue => exception
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  def upload_files
    @folder.update(folder_params)
  rescue
    render json: { message: "Hubo un error al subir los archivos." }, status: :unprocessable_entity
  end

  def folders_payments
    @folders_payments = @folders.map do |folder|
      quotation = get_quotation(folder)
      all_installments = get_active_payments(quotation, folder.installments.includes(payments: :restructure))
      cash_flows = folder.cash_flows
      payments = get_restructures_installments(folder.installments)
      FolderPayment.new(folder, quotation, all_installments, cash_flows, payments)
    end
  end

  def folder_payments
    quotation = get_quotation(@folder)
    all_installments = get_active_payments(quotation, @folder.installments.includes(payments: :restructure))
    cash_flows = @folder.cash_flows
    payments = get_restructures_installments(@folder.installments)
    @folder_payment = FolderPayment.new(@folder, quotation, all_installments, cash_flows, payments)
  end

  def balances_close_to_due
    folder_ids = @folders.where(step: Step.last_step).search(params).pluck(:id)
    folders = Folder.includes(:payment_scheme, :client, :client_2, :client_3, :client_4, :client_5, :client_6, [lot: [stage: :phase]], [user: :structure]).where(id: folder_ids)
    @balances = folders.map do |folder|
      overdue_payments = get_overdue_payments(folder)
      generate_row(folder, overdue_payments, @is_evo)
    end
  end

  def folder_balances_close_to_due
    raise StandardError.new, "Este expediende aún no ha sido aprobado." unless @folder.step.is_last_one?
    folder = Folder.includes(:payment_scheme, :client, :client_2, :client_3, :client_4, :client_5, :client_6, [lot: [stage: :phase]], [user: :structure]).find(@folder.id)
    raise StandardError.new, "La cartera vencida de expediente no fue encontrada" unless folder.present?
    overdue_payments = get_overdue_payments(folder)
    @balance = generate_row(folder, overdue_payments, @is_evo)

  rescue => exception
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  def folders_information
    @folders = Folder.where("id in (?)", folder_report_filter(current_user, params))
  rescue => exception
    render json: { message: exception.message }, status: :unprocessable_entity
  end

  def folder_information
    render json: { message: "No tiene permisos para acceder a este expediente." }, status: :unprocessable_entity if @folder.folder_users.where(user: current_user).empty?
  end

  private

    def set_folder
      @folder = Folder.includes(:payment_scheme, :client, :user, lot: { stage: { phase: :project } }).find(params[:id])
      @folder_without_active_payments = @folder.installments.includes(:payments).where(payments: { status: :active }).empty?
      @can_cancel_folder = can_cancel_folder?
    end

    def can_cancel_folder?
      (@folder_without_active_payments || can?(:cancel_approved_with_payments, Folder)) && @step_role&.can_cancel? && !@folder.canceled?
    end

    def folder_params
      params.permit(:commission_voucher,
                                     :commission_receipt,
                                     :bank_deposit,
                                     :bank_deposit_complement,
                                     :reserve_receipt,
                                     :down_payment_voucher,
                                     :down_payment_receipt,
                                     :conditions_purchase,
                                     :amortization_table,
                                     :federal_cedula,
                                     :agree_letter,
                                     :marriage_act,
                                     :purchase_promise,
                                     :promissory_note)
    end

    def get_quotation(folder)
      discount = folder.payment_scheme.discount
      total_payments = folder.payment_scheme.total_payments
      restructures = folder.get_restructures
      folder.generate_quote(total_payments, discount, restructures)
    end

    def get_active_payments(quotation, installments)
      all_installments = quotation.down_payment_monthly_payments | quotation.amr
      all_installments.each_with_index do |installment, index|
        is_down_payment = index + 1 <= quotation.down_payment_monthly_payments.length
        concept = index == 0 ? Installment::CONCEPT[:INITIAL_PAYMENT] : is_down_payment ? Installment::CONCEPT[:DOWN_PAYMENT] : Installment::CONCEPT[:FINANCING]
        actual = installments.find { |element| (element.number.to_i == installment[:number] || element.number == "A") && element.concept == concept }
        total_amount = installment[:payment].round(2)
        all_installments[index][:residue] = 0
        all_installments[index][:is_next_payment] = false

        if actual.present?
          total_paid = actual.total_paid
          if total_paid >= total_amount
            all_installments[index][:paid] = true
          else
            pending_payment = total_amount - actual.total_paid
            all_installments[index][:residue] = pending_payment
            all_installments[index][:is_next_payment] = true
          end
        end
      end
    end

    def get_restructures_installments(installments)
      Payment.joins(:restructure).includes(:installment).where(installment: installments, cash_flow: nil).where.not(restructure: nil)
    end

    def generate_row(folder, overdue_payments, is_evo)
      { folder: folder, overdue_payments: overdue_payments, is_evo: is_evo }
    end

    def evo
      @is_evo = Role.where(is_evo: true).exists?
    end
end
