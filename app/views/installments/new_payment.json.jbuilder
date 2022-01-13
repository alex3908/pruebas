# frozen_string_literal: true

json.has_bonus_residue @payment_method.present? && @payment_method.cash_back
json.bonus_residue @next_installment.present? ? (@next_installment[:bonus_residue].present? ? @next_installment[:bonus_residue] : 0) : 0
json.cash_back_available @client.cash_back_available(@folder.id, payment_method: @payment_method)
json.can_create_or_update_penalty can?(:create, Penalty) || can?(:update, Penalty)
json.installments do
  json.array! @persisted_installments
end
