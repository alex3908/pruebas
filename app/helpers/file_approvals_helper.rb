# frozen_string_literal: true

module FileApprovalsHelper
  def approval_label_name(approval)
    return "COMPROBANTE DEL PAGO (APARTADO)" if approval.key == "bank_deposit"
    return "COMPLEMENTO DEL PAGO (APARTADO)" if approval.key == "bank_deposit_complement"
    return "COMPROBANTE DEL PAGO (ENGANCHE)" if approval.key == "down_payment_voucher"
    return "IDENTIFICACIÓN OFICIAL" if approval.key == "official_identification"
    return "COMPROBANTE DOMICILIARIO" if approval.key == "address_proof"
    return "ACTA DE NACIMIENTO" if approval.key == "birth_certificate"
    return "CURP" if approval.key == "curp"
    return "ACTA FISCAL" if approval.key == "fiscal_act"
    return "ANTECEDENTES NO PENALES" if approval.key == "non_criminal_record"
    return "REFERENCIAS LABORALES" if approval.key == "job_reference"
    return "CARTA DE RECOMENDACIÓN 1" if approval.key == "recommendation_letter_1"
    return "CARTA DE RECOMENDACIÓN 2" if approval.key == "recommendation_letter_2"
    approval.key
  end

  def approval_amount(approval)
    payment_scheme = approval.approvable.payment_scheme
    return payment_scheme.lock_payment if approval.key == "bank_deposit"
    return payment_scheme.complement_payment if approval.key == "bank_deposit_complement"
    return payment_scheme.down_payment if approval.key == "down_payment_voucher"
    approval.key
  end

  def involved(approval)
    if approval.approvable.documentable_type == "Folder"
      approval.approvable.documentable.lot.full_path("/")
    else
      approval.approvable.documentable.label
    end
  end
end
