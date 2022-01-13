# frozen_string_literal: true

has_warnings = @locals[:warning].present?
has_errors = @locals[:error].present?
if has_warnings
  json.has_warnings has_warnings
  json.warning_message has_warnings ? @installments_helper_for_jbuilder.warning_response_message(@locals[:warning], @locals[:cash_back_available]) : ""
elsif has_errors
  json.has_errors has_errors
  json.error_message has_errors ? @installments_helper_for_jbuilder.error_response_message(@locals[:error]) : ""
else
  json.payment_pdf_url @cash_flow.present? ? invoice_folder_cash_flow_url(@folder, @cash_flow, type: "voucher", download: true, format: :pdf) : invoice_folder_payment_url(@folder, @payment, type: "voucher", download: true, format: :pdf)
  json.redirect_url folder_installments_url(@folder)
end
