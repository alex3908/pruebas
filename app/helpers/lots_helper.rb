# frozen_string_literal: true

module LotsHelper
  def lot_status_class(lot)
    case lot.status_label
    when "Disponible"
      "badge-success"
    when "Reservado"
      "badge-warning"
    when "Vendido"
      "badge-danger"
    else
      "badge-secondary"
    end
  end

  def fa_icon(name, style_class: nil)
    content_tag(:i, class: ["fa", "fa-#{name}", style_class])
  end

  def fa_stack(top, bottom)
    "
    <span class='fa-stack' style='font-size:0.63em;'>
      <i class='fa fa-#{bottom} fa-stack-1x'></i>
      <i class='fa fa-#{top} fa-stack-2x'></i>
    </span>
    ".html_safe
  end
end
