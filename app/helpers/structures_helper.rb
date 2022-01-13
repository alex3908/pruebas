# frozen_string_literal: true

module StructuresHelper
  def structure_status(active)
    active ? "Aprobada" : "Pendiente"
  end

  def singularize_label(subordinate)
    subordinate.singularize(:es)
  end

  def can_it_be_approved_or_rejected?(structure)
    if current_user.structure.present?
      users_to_approve.include?(structure.user.id)
    else
      !structure.active
    end
  end

  def users_to_approve
    raise CanCan::AccessDenied unless current_user.structure.present?
    if current_user.structure.is_root?
      current_user.structure.descendants.pluck(:user_id)
    else
      current_user.structure.indirects.pluck(:user_id)
    end
  end
end
