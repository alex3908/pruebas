namespace :delete_bank_accounts_clabe_white_spaces do
  desc "Deletes every white spaces in bank accounts clabe value"
  
  task run: :environment do
    bank_accounts = BankAccount.all
  
    bank_accounts.each do |bank_account|
      bank_account.update(clabe: bank_account.clabe.gsub(/\s+/, "")) if bank_account.clabe.include?(" ")
    end
  end
end
