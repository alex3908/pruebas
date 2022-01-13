# frozen_string_literal: true

module BlueprintsHelper
  def select_type(extras, type)
    extras.select { |extra| extra.name == type }
  end

  def valid_html_type(html_type)
    html_type == "polygon" || html_type == "path" || html_type == "rect" || html_type == "polyline" || html_type == "circle" || html_type == "line" || html_type == "ellipse"
  end

  def tooltip_stage_label(stage = nil, sale_map: true)
    if stage.present?
      stage.name.html_safe
    elsif !sale_map
      "Sin asignar"
    end
  end

  def tooltip_label(lot = nil, sale_map: true, status: true, area: false)
    if lot.present?
      status = (sale_map) ? lot.status_label_map : lot.status_label
      label = lot.name
      label.concat("<br/>Estado: #{status}") if status
      label.concat("<br/>Sup.: #{"%.2f" % lot.area} m<sup>2</sup>") if area
    elsif !sale_map
      "Sin asignar"
    end
  end

  def blueprint_stage_assignable_class(blueprint_stage)
    if blueprint_stage.stage.present?
      "assigned"
    else
      "stage-assignable"
    end
  end

  def blueprint_stage_class(blueprint_stage, stage, assignable)
    class_style = [ blueprint_stage.html_class ]
    class_style << blueprint_stage_assignable_class(blueprint_stage) if assignable
    class_style << "not-selected-stage" if stage.present? && blueprint_stage.stage != stage
    class_style << "set-empty-fill"
    class_style.join(" ")
  end

  def blueprint_stage_render_tag(blueprint_stage, blueprint, stage: nil, assignable: false)
    style_class = blueprint_stage_class(blueprint_stage, stage, assignable)

    if (stage.nil? && assignable) || blueprint_stage.stage.present?
      tooltip = tooltip_stage_label(blueprint_stage.stage)
    end

    if blueprint_stage.html_type == "polygon"
      stage_polygon(blueprint_stage, blueprint, style_class, tooltip)
    elsif blueprint_stage.html_type == "rect"
      stage_rect(blueprint_stage, blueprint, style_class, tooltip)
    elsif blueprint_stage.html_type == "polyline"
      stage_polyline(blueprint_stage, blueprint, style_class, tooltip)
    elsif blueprint_stage.html_type == "path"
      stage_path(blueprint_stage, blueprint, style_class, tooltip)
    end
  end

  def stage_polygon(blueprint_stage, blueprint, style_class, tooltip)
    tag(:polygon, class: "no-outline stage-figure #{style_class}",
      points: blueprint_stage.points,
      "data-blueprint-stage-id": blueprint_stage.id,
      "data-stage-id": blueprint_stage.stage_id,
      "data-blueprint-id": blueprint.id,
      rel: "tooltip",
      "data-html": "true",
      title: tooltip
    )
  end

  def stage_path(blueprint_stage, blueprint, style_class, tooltip)
    tag(:path, class: "no-outline stage-figure #{style_class}",
      d: blueprint_stage.d,
      "data-blueprint-stage-id": blueprint_stage.id,
      "data-stage-id": blueprint_stage.stage_id,
      "data-blueprint-id": blueprint.id,
      rel: "tooltip",
      "data-html": "true",
      title: tooltip
    )
  end

  def stage_rect(blueprint_stage, blueprint, style_class, tooltip)
    tag(:rect, class: "no-outline stage-figure #{style_class}",
      x: blueprint_stage.x,
      y: blueprint_stage.y,
      width: blueprint_stage.width,
      height: blueprint_stage.height,
      transform: blueprint_stage.transform,
      "data-blueprint-stage-id": blueprint_stage.id,
      "data-stage-id": blueprint_stage.stage_id,
      "data-blueprint-id": blueprint.id,
      rel: "tooltip",
      "data-html": "true",
      title: tooltip
    )
  end

  def stage_polyline(blueprint_stage, blueprint, style_class, tooltip)
    tag(:polyline, class: "no-outline stage-figure #{style_class}",
      points: blueprint_stage.points,
      "data-blueprint-stage-id": blueprint_stage.id,
      "data-stage-id": blueprint_stage.stage_id,
      "data-blueprint-id": blueprint.id,
      rel: "tooltip",
      "data-html": "true",
      title: tooltip
    )
  end

  def blueprint_lot_assignable_class(blueprint_lot)
    if blueprint_lot.lot&.present?
      "assigned"
    else
      "assignable"
    end
  end

  def blueprint_lot_class(blueprint_lot, lot, sale_map, assignable, texts)
    class_style = [ blueprint_lot.html_class ]
    class_style << blueprint_lot_assignable_class(blueprint_lot) if assignable && !texts
    class_style << "selected-lot" if lot.present? && blueprint_lot.lot == lot
    class_style << blueprint_lot.lot.key_label if blueprint_lot.lot.present? && !texts
    class_style.join(" ")
  end

  def blueprint_lot_render_tag(blueprint_lot, blueprint, lot: nil, texts: false, sale_map: false, show_tooltip: true, assignable: false)
    style_class = blueprint_lot_class(blueprint_lot, lot, sale_map, assignable, texts)
    tooltip = tooltip_label(blueprint_lot.lot, sale_map: sale_map, area: !assignable) if show_tooltip && (blueprint_lot.lot.present? || assignable && !sale_map)
    style = lot_style(blueprint_lot.lot, sale_map)

    if blueprint_lot.html_type == "polygon"
      lot_polygon(blueprint_lot, blueprint, style_class, tooltip, style)
    elsif blueprint_lot.html_type == "rect"
      lot_rect(blueprint_lot, blueprint, style_class, tooltip, style)
    elsif blueprint_lot.html_type == "polyline"
      lot_polyline(blueprint_lot, blueprint, style_class, tooltip, style)
    elsif blueprint_lot.html_type == "path"
      lot_path(blueprint_lot, blueprint, style_class, tooltip, style)
    end
  end

  def lot_polygon(blueprint_lot, blueprint, style_class, tooltip, style)
    tag(:polygon, class: "no-outline lot-figure #{style_class}",
      points: blueprint_lot.points,
      style: style,
      "data-blueprint-lot-id": blueprint_lot.id,
      "data-blueprint-id": blueprint_lot.blueprint_id,
      "data-id": blueprint_lot.lot&.id,
      "data-project_id": blueprint_lot.lot&.stage&.phase&.project_id,
      "data-stage_id": blueprint_lot.lot&.stage_id,
      rel: "tooltip",
      "data-html": "true",
      "data-placement": "top",
      title: tooltip
    )
  end

  def lot_path(blueprint_lot, blueprint, style_class, tooltip, style)
    tag(:path, class: "no-outline lot-figure #{style_class}",
      d: blueprint_lot.d,
      style: style,
      "data-blueprint-lot-id": blueprint_lot.id,
      "data-blueprint-id": blueprint_lot.blueprint_id,
      "data-id": blueprint_lot.lot&.id,
      "data-project_id": blueprint_lot.lot&.stage&.phase&.project_id,
      "data-stage_id": blueprint_lot.lot&.stage_id,
      rel: "tooltip",
      "data-html": "true",
      "data-placement": "top",
      title: tooltip
    )
  end

  def lot_rect(blueprint_lot, blueprint, style_class, tooltip, style)
    tag(:rect, class: "no-outline lot-figure #{style_class}",
      x: blueprint_lot.x,
      y: blueprint_lot.y,
      width: blueprint_lot.width,
      height: blueprint_lot.height,
      transform: blueprint_lot.transform,
      style: style,
      "data-blueprint-lot-id": blueprint_lot.id,
      "data-blueprint-id": blueprint_lot.blueprint_id,
      "data-id": blueprint_lot.lot&.id,
      "data-project_id": blueprint_lot.lot&.stage&.phase&.project_id,
      "data-stage_id": blueprint_lot.lot&.stage_id,
      rel: "tooltip",
      "data-html": "true",
      "data-placement": "top",
      title: tooltip
    )
  end

  def lot_polyline(blueprint_lot, blueprint, style_class, tooltip, style)
    tag(:polyline, class: "no-outline lot-figure #{style_class}",
      points: blueprint_lot.points,
      style: style,
      "data-blueprint-lot-id": blueprint_lot.id,
      "data-blueprint-id": blueprint_lot.blueprint_id,
      "data-id": blueprint_lot.lot&.id,
      "data-project_id": blueprint_lot.lot&.stage&.phase&.project_id,
      "data-stage_id": blueprint_lot.lot&.stage_id,
      rel: "tooltip",
      "data-html": "true",
      "data-placement": "top",
      title: tooltip
    )
  end

  def lot_style(lot, sale_map)
    sale_map && lot&.color.present? && lot.for_sale? ? "fill:#{lot.color}!important" : nil
  end

  def blueprint_extra_render_tag(extra)
    case extra.html_type
    when "polygon"
      extra_polygon(extra)
    when "path"
      extra_path(extra)
    when "rect"
      extra_rect(extra)
    when "polyline"
      extra_polyline(extra)
    when "circle"
      extra_circle(extra)
    when "line"
      extra_line(extra)
    when "ellipse"
      extra_ellipse(extra)
    end
  end

  def extra_polygon(extra)
    tag(:polygon, class: extra.html_class,
      points: extra.points,
    )
  end

  def extra_path(extra)
    tag(:path, class: extra.html_class,
      d: extra.d,
    )
  end

  def extra_rect(extra)
    tag(:rect, class: extra.html_class,
      x: extra.x,
      y: extra.y,
      transform: extra.transform,
      width: extra.width,
      height: extra.height,
    )
  end

  def extra_polyline(extra)
    tag(:polyline, class: extra.html_class,
      points: extra.points,
    )
  end

  def extra_circle(extra)
    tag(:circle, class: extra.html_class,
      cx: extra.cx,
      cy: extra.cy,
      r: extra.r,
    )
  end

  def extra_line(extra)
    tag(:line, class: extra.html_class,
      x1: extra.x1,
      y1: extra.y1,
      x2: extra.x2,
      y2: extra.y2,
    )
  end

  def extra_ellipse(extra)
    tag(:ellipse, class: extra.html_class,
      cx: extra.cx,
      cy: extra.cy,
      rx: extra.rx,
      ry: extra.ry,
    )
  end
end
