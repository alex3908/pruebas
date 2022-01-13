# frozen_string_literal: true

class CashBacksController < ApplicationController
  load_and_authorize_resource
  before_action :set_client

  def new
    @folder = Folder.find(params[:folder_id])
    @payment_methods = PaymentMethod.with_cash_back
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @cash_back.user = current_user
    @cash_back.exclusive_folder_id = nil unless @cash_back.payment_method.cash_back_folder_exclusivity?
    @cash_back.client = @client
    @cash_back.save

    respond_to do |format|
      format.js
    end
  end

  def cancel
    @cash_back.canceled_by = current_user
    @cash_back.canceled_at = Time.zone.now
    @cash_back.save

    respond_to do |format|
      format.js
    end
  end

  private

    def cash_back_params
      params.require(:cash_back).permit(:client_id,
                                        :user_id,
                                        :amount,
                                        :exclusive_folder_id,
                                        :payment_method_id)
    end

    def set_client
      @client = Client.find(params[:client_id])
    end
end
