# frozen_string_literal: true

class BankAccountsController < ApplicationController
  include BankAccountsHelper
  load_and_authorize_resource
  before_action :set_parent
  before_action :set_bank_accounts, only: [:index]
  before_action :set_bank_account, except: [:index, :new, :create]
  before_action :delete_white_spaces, only: [:create, :update]

  # GET /bank_accounts
  def index
    @per_page = params[:per_page].to_i < 1 ? @per_page_default : params[:per_page] || @per_page_default
    @bank_accounts = @bank_accounts.order(created_at: :asc).paginate(page: params[:page], per_page: @per_page)
  end

  # GET /bank_accounts/1
  def show
  end

  # GET /bank_accounts/new
  def new
    @bank_account = BankAccount.new
  end

  # GET /bank_accounts/1/edit
  def edit
  end

  # POST /bank_accounts
  def create
    @bank_account = @parent.bank_accounts.build(@bank_account_params)
    if @bank_account.save
      flash[:success] = "Cuenta de banco creada correctamente."
      redirect_to parent_bank_account_path
    else
      render :new
    end
  end

  # PATCH/PUT /bank_accounts/1
  def update
    if @bank_account.update(@bank_account_params)
      flash[:success] = "Cuenta de banco editada correctamente."
      redirect_to parent_bank_account_path
    else
      render :edit
    end
  end

  # DELETE /bank_accounts/1
  def destroy
    if @bank_account.principal?
      flash[:error] = "No es posible eliminar la cuenta principal"
    else
      @bank_account.destroy
      flash[:success] = "Cuenta de banco eliminada correctamente."
    end
    redirect_to parent_bank_account_path
  end

  def change_status
    @bank_account.toggle!(:active)
  end

  private

    def bank_account_params
      params.require(:bank_account).permit(:holder, :bank, :account_number, :currency, :clabe, :principal)
    end

    def set_parent
      parent_klasses = %w[enterprise user]
      if klass = parent_klasses.detect { |pk| params[:"#{pk}_id"].present? }
        @parent = klass.camelize.constantize.find(params[:"#{klass}_id"])
      end
    end

    def set_bank_account
      @bank_account = BankAccount.find_by(payable: @parent, id: params[:id])
    end

    def set_bank_accounts
      if request.path == enterprise_bank_accounts_path(@parent)
        @bank_accounts = BankAccount.where(payable_type: @parent.class.to_s, payable: @parent)
      else
        @bank_account = BankAccount.find(params[:id])
      end
    end

    def delete_white_spaces
      @bank_account_params = bank_account_params
      @bank_account_params[:clabe] = @bank_account_params[:clabe].gsub(/\s+/, "")
    end
end
