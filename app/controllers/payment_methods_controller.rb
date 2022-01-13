# frozen_string_literal: true

class PaymentMethodsController < ApplicationController
  load_and_authorize_resource

  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @payment_methods = @payment_methods.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)

    respond_to do |format|
      format.html
      format.json {
        render json: @payment_methods.autocomplete(params[:search])
      }
    end
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    if @payment_method.save
      flash[:success] = "Método de pago creado correctamente."
      redirect_to payment_methods_path
    else
      render :new
    end
  end

  def update
    if @payment_method.update(payment_method_params)
      flash[:success] = "Método de pago editado correctamente."
      redirect_to payment_methods_path
    else
      render :edit
    end
  end

  def destroy
    @payment_method.destroy
    flash[:success] = "Método de pago eliminado correctamente."
    redirect_to payment_methods_path
  end

  private

    def payment_method_params
      params.require(:payment_method).permit(:name,
                                             :cash_back,
                                             :capital,
                                             :down_payment,
                                             :interest,
                                             :cash_back_folder_exclusivity,
                                             :active,
                                             :add_balance,
                                             :reffered_client_cash_back,
                                             :payment_is_income,
                                             :reffered_client_cash_back_multiple)
    end
end
