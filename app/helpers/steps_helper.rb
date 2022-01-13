# frozen_string_literal: true

module StepsHelper
  def checkbox(form, size, key, opts = {})
    form.check_box key, { data: {
      activate: "toggle",
      size: size,
      onstyle: key != :_destroy ? "success" : "danger",
      offstyle: key != :_destroy ? "secondary" : "light",
      on: opts.fetch(:on_label, on_icon(key)),
      off: opts.fetch(:off_label, off_icon(key))
    } }
  end

  def ajax_checkbox(step_role, index)
    check_box_tag(:document, index, step_role.downloadable_files.where(document: index).present?, { data: {
        activate: "toggle",
        onstyle: "success",
        offstyle: "secondary",
        on: tag.i("", class: "fa fa-eye", "aria-hidden": "true"),
        off: tag.i("", class: "fa fa-eye-slash", "aria-hidden": "true"),
        remote: true,
        url: allow_downloadable_step_step_roles_path(step_id: params[:id], step_role_id: step_role.id, document_id: index),
        method: :patch
    } })
  end

  def step_role_icon(button_type, key)
    if key == :_destroy
      tag.i("", class: "fa fa-trash", "aria-hidden": "true")
    elsif button_type == "on"
      tag.i("", class: "fa fa-check", "aria-hidden": "true")
    elsif button_type == "off"
      tag.i("", class: "fa fa-times", "aria-hidden": "true")
    end
  end

  private
    def on_icon(key)
      step_role_icon("on", key)
    end

    def off_icon(key)
      step_role_icon("off", key)
    end
end
