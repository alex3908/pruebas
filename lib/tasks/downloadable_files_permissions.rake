# frozen_string_literal: true

namespace :downloadable_files_permissions do
  desc "Migrate downloadables files permissions into dinamic per step per role permission"

  task run: :environment do
    @steps = Step.all
    @steps.each do |step|
      step.step_roles.each do |step_role|
        step_role.downloadable_files.find_or_create_by(document: 0) if step_role.role.permissions.where(subject_class: "Folder", action: ["purchase_promise", "purchase_promise_only"]).present?
        step_role.downloadable_files.find_or_create_by(document: 1) if step_role.role.permissions.where(subject_class: "Folder", action: "annexe_1").present?
        step_role.downloadable_files.find_or_create_by(document: 2) if step_role.role.permissions.where(subject_class: "Folder", action: "annexe_2").present?
        step_role.downloadable_files.find_or_create_by(document: 3) if step_role.role.permissions.where(subject_class: "Folder", action: "annexe_3").present?
        step_role.downloadable_files.find_or_create_by(document: 4) if step_role.role.permissions.where(subject_class: "Folder", action: "purchase_promise_attached").present? # PLD
        step_role.downloadable_files.find_or_create_by(document: 5) if step_role.role.permissions.where(subject_class: "Folder", action: "amortization_cover").present?
        step_role.downloadable_files.find_or_create_by(document: 6) if step_role.role.permissions.where(subject_class: "Folder", action: "deposit_format").present?
        step_role.downloadable_files.find_or_create_by(document: 7) if step_role.role.permissions.where(subject_class: "Folder", action: "down_payment_receipt").present?
        step_role.downloadable_files.find_or_create_by(document: 8) if step_role.role.permissions.where(subject_class: "Folder", action: "purchase_conditions").present?
        step_role.downloadable_files.find_or_create_by(document: 9) if step_role.role.permissions.where(subject_class: "Folder", action: "amortization_table").present?
        step_role.downloadable_files.find_or_create_by(document: 10) if step_role.role.permissions.where(subject_class: "Folder", action: "promissory_note").present?
      end
    end
  end

  task delete_old_permissions: :environment do
    Permission.find_by(subject_class: "Folder", action: "deposit_format").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "down_payment_receipt").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "amortization_table").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "amortization_cover").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "purchase_conditions").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "promissory_note").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "purchase_promise_only").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "purchase_promise_attached").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "annexe_1").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "annexe_2").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "annexe_3").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "view_active_promise").try(:destroy)
    Permission.find_by(subject_class: "Folder", action: "view_active_promise_only").try(:destroy)
  end
end
