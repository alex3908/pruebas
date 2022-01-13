# frozen_string_literal: true

module CreditSchemesHelper
  def quotation_type_label(key)
    I18n.t("activerecord.attributes.credit_scheme.quotation.#{key}")
  end

  def quotation_type_options
    CreditScheme.quotation_types.keys.map { |key| [quotation_type_label(key), key] }
  end

  def base_discount(form_builder)
    discount = form_builder.object.discount.to_f
    (discount * 100).round(2)
  end
end
