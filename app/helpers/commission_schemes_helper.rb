# frozen_string_literal: true

module CommissionSchemesHelper
  def labels_for_commission_scheme_form
    {
      table_columns: [
        CommissionSchemesRole.human_attribute_name(:role_id),
        CommissionSchemesRole.human_attribute_name(:folder_user_concept_id),
        CommissionSchemesRole.human_attribute_name(:commission),
        ""
      ],
      confirmation_destroy: t("confirmations.destroy_with_relations?"),
      button_deleted: t("buttons.destroy")
    }
  end

  def params_commission_schemes_role_component(is_evo)
    {
      section_title: t("commission_schemes.form.commission_for", for: (is_evo ? @evo_string : t(".others"))),
      labels: labels_for_commission_scheme_form,
      commissions: @commission_scheme.commission_schemes_roles.joins(:role).where(roles: { is_evo: is_evo }),
      roles: is_evo ? @roles_evo : @roles_no_evo,
      folder_user_concepts: @folder_user_concepts
    }
  end
end
