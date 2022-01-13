# frozen_string_literal: true

class CashFlowsController < ApplicationController
  include QuotationsHelper
  load_and_authorize_resource
  before_action :set_folder, except: [:import]
  before_action :generate, only: [:invoice]

  def invoice
    voucher = (params[:type] == "voucher")
    disposition = (params[:download] == "true") ? "attachment" : "inline"
    invoice = @cash_flow.to_file(false, voucher, voucher)

    respond_to do |format|
      format.pdf { send_data invoice.to_pdf, filename: "invoice.pdf", type: "application/pdf", disposition: disposition }
      format.html { render html: invoice.render_to_string } unless Rails.env.production?
    end
  end

  def cancel
    locals = {}
    cash_flow = CashFlow.find(params[:id])
    ActiveRecord::Base.transaction(requires_new: true) do
      if params[:cancelation_description].blank?
        locals[:message] = "empty_description"
      else
        begin
          cash_flow.update!(status: Payment::STATUS[:CANCELED], canceled_by: current_user, cancellation_date: Time.zone.now, cancelation_description: params[:cancelation_description])
          locals[:message] = "canceled_payment"
          cash_flow.payments.each { |payment| payment.update(status: Payment::STATUS[:CANCELED], canceled_by: current_user) }
        rescue
          locals[:message] = "error"
          cash_flow.update!(status: Payment::STATUS[:ACTIVE], canceled_by: nil, cancellation_date: nil)
        end
      end

      cash_flow.cash_back_flows.destroy_all
    end
  rescue
    locals[:message] = "error"
  ensure
    respond_to do |format|
      format.js { render "payments/cancel", locals: locals }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.js
    end
  end

  def update
    respond_to do |format|
      if @cash_flow.update(cash_flow_params)
        format.html { redirect_to folder_payments_path(@folder), notice: "El flujo de caja fue actualizado." }
        format.json { render :show, status: :ok, location: @period }
      else
        format.html { redirect_to folder_payments_path(@folder), error: "Hubo un error al actualizar el flujo de caja." }
        format.json { render json: @cash_flow.errors, status: :unprocessable_entity }
      end
    end
  end

  def see_cancel_modal
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def set_folder
      @folder = Folder.find(params[:folder_id])
      @client = @folder.client
      @project = @folder.project
      @phase = @folder.phase
      @stage = @folder.stage
      @lot = @folder.lot
      @payment_scheme = @folder.payment_scheme
    end

    def generate
      @quotation = @folder.generate_quote
    end

    def cash_flow_params
      params.require(:cash_flow).permit(:voucher)
    end
end
