# frozen_string_literal: true

module CashFlowHelper
  def concept_with_percentage(cash_flow,  only_concept_name = false, splitter = "|")
    split_concepts(cash_flow.concept, only_concept_name, splitter).join(tag.br).html_safe
  end

  def split_concepts(concepts, only_concept_name, splitter)
    splitted_concepts = []

    concepts.each do |key, concept|
      if concept.any?
        splitted_concepts << I18n.t("activerecord.attributes.installment.concept_keys.#{key}")
        unless only_concept_name
          concept.each_with_index do |concept_value, index|
            splitted_concepts[-1] += " #{concept_value[:restructure_concept]}" if concept_value.include?(:restructure_concept)
            splitted_concepts[-1] += " #{concept_value[:concept_name]}" if concept_value.include?(:concept_name)
            splitted_concepts[-1] += " #{concept_value[:number]}" if concept_value.include?(:number)
            splitted_concepts[-1] += " #{concept_value[:term]}" if concept_value.include?(:term)
            splitted_concepts[-1] += " #{number_to_currency(concept_value[:currency])}" if concept_value.include?(:currency)
            splitted_concepts[-1] += "(#{'%.2f' % concept_value[:percentage]}%)" if concept_value.include?(:percentage)
            splitted_concepts[-1] += "," unless index == concept.length - 1
          end
        end
      end
    end

    splitted_concepts
  end

  def concepts_array(concepts)
    splitted_concepts = []

    concepts.each do |key, concept|
      if concept.any?
        concept.each_with_index do |concept_value, index|
          splitted_concepts << { name: I18n.t("activerecord.attributes.installment.concept_keys.#{key}"),
          identifier: (concept_value.include?(:number) ? " #{concept_value[:number]}" : ""),
          percentaje: (concept_value.include?(:percentage) ? "#{'%.2f' % concept_value[:percentage]}" : "N/A"),
          currency: (concept_value.include?(:currency) ? "#{concept_value[:currency]}" : "") }
        end
      end
    end

    splitted_concepts
  end
end
