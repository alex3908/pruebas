# frozen_string_literal: true

class ContractDocumentTemplate < ApplicationRecord
  belongs_to :contract
  belongs_to :document_template
end
