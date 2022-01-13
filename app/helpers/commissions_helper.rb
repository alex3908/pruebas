# frozen_string_literal: true

module CommissionsHelper
  include QuotationsHelper

  def create_folder_users(folder)
    user = folder.user
    structure = user.structure
    referent = Referent.find_by(invited: user)
    commission_scheme = folder.lot.stage.commission_scheme
    commission_scheme_roles = folder.lot.stage.commission_schemes_roles
                                              .joins(:folder_user_concept)
                                              .select("role_id", "folder_user_concepts.key AS key", "commission")
                                              .to_a

    if referent.present?
      if structure.nil? || structure.present? &&
          structure.ancestors.pluck(:user_id).exclude?(referent.referrer_id) &&
          structure.subtree.pluck(:user_id).exclude?(referent.referrer_id)
        save_folder_user(referent.referrer, folder, commission_scheme.global_commission, FolderUserConcept.find_by_key(FolderUser::CONCEPT[:REFERRED]), false)
      end
    end

    sale_commission_role = commission_scheme_roles.find { |csr| csr.role_id == user.role_id && csr.key == FolderUser::CONCEPT[:SALE] }
    sale_commission = sale_commission_role.present? ? sale_commission_role.commission : 0
    save_folder_user(user, folder, sale_commission, FolderUserConcept.find_by_key(FolderUser::CONCEPT[:SALE]))

    if structure.present?
      folder_user_concept_follow_up = FolderUserConcept.find_by_key(FolderUser::CONCEPT[:FOLLOW_UP])

      structure.ancestors.each do |ancestor|
        ancestor_commission_role = commission_scheme_roles.find { |csr| csr.role_id == ancestor.role_id && csr.key == FolderUser::CONCEPT[:FOLLOW_UP] }
        follow_up_commission = ancestor_commission_role.present? ? ancestor_commission_role.commission : 0

        if ancestor.user_id.present?
          save_folder_user(ancestor.user, folder, follow_up_commission, folder_user_concept_follow_up)
        end
      end
    end

    folder.lot.stage.stages_commission_schemes_roles.each do |stage_commission_scheme_role|
      stage_commission_scheme_role.users.reject(&:blank?).each do |user_id|
        user = User.find(user_id)
        save_folder_user(user, folder, stage_commission_scheme_role.commission, stage_commission_scheme_role.folder_user_concept)
      end
    end
  end

  def save_folder_user(user, folder, percentage, folder_user_concept, visible = true)
    FolderUser.create(user: user, role: user.role, folder: folder, percentage: percentage, concept: folder_user_concept.key, visible: visible, folder_user_concept: folder_user_concept)
  end

  def get_total_amount(commission)
    promo = promotion_calculator(
      commission.folder_user.folder.payment_scheme.buy_price * commission.folder_user.folder.lot.area,
        commission.folder_user.folder.payment_scheme.discount,
        commission.folder_user.folder.payment_scheme.promotion_discount,
        commission.folder_user.folder.payment_scheme.promotion_operation,
        commission.folder_user.folder.payment_scheme.promotion&.amount || 0,
        commission.folder_user.folder.payment_scheme.promotion&.operation || nil,
        commission.folder_user.folder.payment_scheme.coupon&.promotion&.amount || 0,
        commission.folder_user.folder.payment_scheme.coupon&.promotion&.operation || nil
    )
    promo.total
  end
end
