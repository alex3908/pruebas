# frozen_string_literal: true

module PromotionsHelper
  def attributes_changes(promotion)
    rows = ""
    promotion.changed.each do |attribute|
      new_value = promotion[:"#{attribute}"]
      new_value_translation = (new_value.in?([true, false])) ? t("activerecord.attributes.promotion.#{new_value}") : new_value
      rows += "<tr><td>#{Promotion.human_attribute_name(attribute)}</td><td>#{new_value_translation}</td></tr>"
    end
    changes_table = "<div class='scroll-table-modal'><table class='table table-bordered background-white'><thead><tr><th width='50%'>Campo</th><th width='50%'>Nuevo valor</th></tr></thead><tbody>#{rows}</tbody></table></div>".html_safe
    changes_table
  end
end
