# frozen_string_literal: true

class PurchasePromiseSignatureServiceJob < ApplicationJob
  queue_as :high_priority
  include SignatureServiceConcern, ContractsHelper

  def perform(folder, digital_signature_service, digital_signature)
    return unless folder.ruled_contract.present?
    signers_array = []
    signer_errors = []

    contract_definitions = contract_definitions(folder.ruled_contract)
    purchase_promise_pdf = PurchasePromiseJob.perform_now(folder.id, nil, true)
    pages = purchase_promise_pdf[:pages]

    folder.clients.each_with_index do |client, index|
      next if contract_definitions[index].nil? && client.nil?
      signers_array << set_signer_structure(client, contract_definitions[index], get_signature_coordinates(client.sign_tag, pages), digital_signature_service.is_shield_level_three_clients, false, false)
    end

    folder.ruled_contract.signers.each do |signer|
      signers_array << set_signer_structure(signer, signer.definition, get_signature_coordinates(signer.sign_tag, pages), digital_signature_service.is_shield_level_three_signers, false, false)
    end

    folder.ruled_contract.non_signers.each do |non_signer|
      signers_array << set_signer_structure(non_signer, non_signer.definition, get_signature_coordinates(non_signer.sign_tag, pages), digital_signature_service.is_shield_level_three_signers, true, true)
    end

    signers_array.each do |signer|
      if !signer[:name].present? || (!signer[:last_name].present? && signer[:obligation].to_sym == :individual) || (!signer[:representative].present? && signer[:obligation].to_sym == :legal) || !signer[:role].present? || !signer[:email].present?
        signer_errors << signer.slice!(:obligation, :coordinates, :is_shield_level_three, :isNotNegotiator, :isNotSigner).map { |key, value| "#{I18n.t("signers.signature_info.#{key}")}: #{value.blank? ? "[VACÍO]" : value}" }.join(", ")
      end
    end

    unless signer_errors.empty?
      digital_signature.update(status: DigitalSignature.statuses[:failed], error_description: "La informacion de uno o más participantes no está completa: #{signer_errors.join(", ")}")
      return
    end

    base64 = Base64.strict_encode64(purchase_promise_pdf[:file])

    update_digital_signature(folder, purchase_promise_pdf[:file_name], digital_signature_service, base64, digital_signature, signers_array)
  rescue StandardError => e
    if digital_signature.present?
      digital_signature.update_attributes({ status: DigitalSignature.statuses[:failed], error_description: "Error de envio de datos" })
    end

    Bugsnag.notify(e) do |report|
      report.add_tab(:trato_error_response, e)
    end
  end
end
