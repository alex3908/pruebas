# frozen_string_literal: true

module UsersHelper
  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end


  def approved_label_result(approval)
    if approval.present? && !approval.unchecked?
      user = approval.approved_by.label
      reason = approval.comment
      if approval.approved?
        "Aprobado por #{user}"
      elsif approval.rejected?
        "Rechazado por #{user}: #{reason}"
      end
    else
      "En Revisión"
    end
  end

  def user_status(active)
    active ? "Activa" : "Inactiva"
  end
end
