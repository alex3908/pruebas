# frozen_string_literal: true

class ContractSigner < ApplicationRecord
  belongs_to :contract
  belongs_to :signer
end
