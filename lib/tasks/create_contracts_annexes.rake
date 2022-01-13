# frozen_string_literal: true

namespace :create_contracts_annexes do
  desc "Run create all contracts it's contract-annexes"
  task run: :environment do
    Contract.all.each do |contract|
      contract.touch
    end
  end
end
