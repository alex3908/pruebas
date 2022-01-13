# frozen_string_literal: true

module AdditionalConceptsHelper
  def amount_type_label(key)
    I18n.t("activerecord.attributes.additional_concept.amount_types.#{key}")
  end

  def amount_type_options
    AdditionalConcept.amount_types.keys.map { |key| [amount_type_label(key), key] }
  end

  def amount_type_by_value(additional_concept)
    return I18n.t("activerecord.attributes.additional_concept.amount_types.fixed") if additional_concept.fixed?

    return I18n.t("activerecord.attributes.additional_concept.amount_types.variable") if additional_concept.variable?

    ""
  end
end
