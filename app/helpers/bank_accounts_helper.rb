# frozen_string_literal: true

module BankAccountsHelper
  def parent_bank_account_path
    if @parent.class == User
      edit_user_registration_path
    elsif @parent.class == Enterprise
      enterprise_bank_account_path(@parent, @bank_account)
    end
  end

  def parent_bank_accounts_path
    if @parent.class == User
      edit_user_registration_path
    elsif @parent.class == Enterprise
      enterprise_bank_accounts_path(@parent)
    end
  end

  def edit_parent_bank_accounts_path(bank_account)
    if @parent.class == User
      edit_user_bank_account_path(@parent, bank_account)
    elsif @parent.class == Enterprise
      edit_enterprise_bank_account_path(@parent, bank_account)
    end
  end
end
