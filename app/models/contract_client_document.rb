# frozen_string_literal: true

class ContractClientDocument < ApplicationRecord
  belongs_to :contract

  DOCUMENTS = { "Identificación oficial": "official_identification",
                "CURP": "curp",
                "Comprobante de domicilio": "address_proof",
                "Acta constitutiva": "constitutional_act",
                "Acta fiscal": "fiscal_act",
                "Acta de nacimiento": "birth_certificate" }
end
