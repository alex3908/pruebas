# frozen_string_literal: true

class ContractNonSigner < ApplicationRecord
  belongs_to :contract
  belongs_to :non_signer, class_name: "Signer", foreign_key: "non_signer_id"
end
