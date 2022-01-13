# frozen_string_literal: true

namespace :discounts do
  desc "Change permissions"
  task copy_permissions: :environment do
    last_permission = Permission.find_by(subject_class: "PaymentPlan", action: "read")
    new_permission = Permission.find_by(subject_class: "Discount", action: "read")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)

    last_permission = Permission.find_by(subject_class: "PaymentPlan", action: "create")
    new_permission = Permission.find_by(subject_class: "Discount", action: "create")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)

    last_permission = Permission.find_by(subject_class: "PaymentPlan", action: "update")
    new_permission = Permission.find_by(subject_class: "Discount", action: "update")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)

    last_permission = Permission.find_by(subject_class: "PaymentPlan", action: "destroy")
    new_permission = Permission.find_by(subject_class: "Discount", action: "destroy")
    last_permission.role_permissions.each do |role_permission|
      new_permission.role_permissions.find_or_create_by(role_id: role_permission.role_id)
    end
    last_permission.try(:destroy)
  end
end
