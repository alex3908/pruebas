# frozen_string_literal: true

namespace :roles do
  desc "Update the evo role levels"
  task update_levels: :environment do
    director_role = Role.find_by(key: "director")
    vice_director_role = Role.find_by(key: "vice_director")
    manager_role = Role.find_by(key: "manager")
    coordinator_role = Role.find_by(key: "coordinator")
    salesman_role = Role.find_by(key: "salesman")
    realtor_role = Role.find_by(key: "realtor")

    ActiveRecord::Base.transaction do
      director_role.update!(level: 0)
      vice_director_role.update!(level: 1)
      manager_role.update!(level: 2)
      coordinator_role.update!(level: 3)
      salesman_role.update!(level: 4)
      realtor_role.update!(level: 5)
    end
  end

  desc "Updating of commissions in roles"
  task commissions_settings_update: :environment do
    ActiveRecord::Base.transaction do
      Role.all.each do |role|
        commission = Setting.find_by(key: "#{role.key}_commission")
        if commission.present?
          role.commission_monitoring = commission&.value.presence || 0
          commission.destroy!
        end

        sale_commission = Setting.find_by(key: "#{role.key}_sale_commission")
        if sale_commission.present?
          role.sale_commission = sale_commission&.value.presence || 0
          sale_commission.destroy!
        end

        max_branches = Setting.find_by(key: "maximum_#{role.key}_schemes")
        if max_branches.present?
          role.maximum_schemes = max_branches&.value.presence || 0
          max_branches.destroy!
        end

        role.save!
      end
    end
  end

  desc "Permissions adjustments"
  task permissions_adjustments: :environment do
    Permission.find_by(subject_class: "CashFlow", action: "update").update(name: "Cargar comprobante")

    last_permission = Permission.find_by(subject_class: "Folder", action: "apply_capital_with_overdue")
    new_permission = Permission.find_by(subject_class: "Installment", action: "apply_capital_with_overdue")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)

    last_permission = Permission.find_by(subject_class: "Payment", action: "read")
    new_permission = Permission.find_by(subject_class: "CashFlow", action: "read")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)

    last_permission = Permission.find_by(subject_class: "Payment", action: "cancel")
    new_permission = Permission.find_by(subject_class: "CashFlow", action: "cancel")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)

    last_permission = Permission.find_by(subject_class: "Payment", action: "resend_notification")
    new_permission = Permission.find_by(subject_class: "CashFlow", action: "resend_notification")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)
  end
end
