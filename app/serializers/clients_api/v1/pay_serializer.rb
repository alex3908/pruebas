# frozen_string_literal: true

class ClientsApi::V1::PaySerializer < ClientsApi::V1::ObjectSerializer
  attributes :status, :transaction_token, :amount, :redirect

    private

      def status
        "#{I18n.t("online_payment_response.statuses.#{object[:status]}")}"
      end
end
