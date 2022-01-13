# frozen_string_literal: true

class AddPolymorphicRelationToBankAccounts < ActiveRecord::Migration[5.2]
  def change
    add_reference :bank_accounts, :payable, polymorphic: true
    reversible do |dir|
      dir.up { BankAccount.update_all("payable_id = enterprise_id, payable_type='Enterprise'") }
      dir.down { BankAccount.update_all("enterprise_id = payable_id") }
    end
    remove_reference :bank_accounts, :enterprise, index: true, foreign_key: true
  end
end
