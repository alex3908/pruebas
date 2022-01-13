# frozen_string_literal: true

class SupportSale < ApplicationRecord
  scope :active, -> { where.not(status: "canceled") }

  enum status: HashWithIndifferentAccess.new(
    creation: "creation",
    support_review: "support_review",
    rejected: "rejected",
    canceled: "canceled",
    approved: "approved",
  )

  belongs_to :folder
  belongs_to :requester, class_name: "User"
  belongs_to :supporter, class_name: "User", optional: true
  belongs_to :support_coordinator, class_name: "User", optional: true
  belongs_to :support_manager, class_name: "User", optional: true
  belongs_to :support_vicedirector, class_name: "User", optional: true

  has_paper_trail skip: [:updated_at], on: [:update]

  validates :status, presence: true

  before_validation :initialize_status

  before_save :set_review_status, if: :support_manager_assigned
  before_save :set_approved_status, if: :supporter_selected
  before_save :reject_or_cancel_revertions
  after_create :notify_request
  after_create :halve_vicedirector_commission
  after_update :assign_and_notify_support, unless: :was_rejected
  after_update :notify_reject, if: :was_rejected

  def involved_users
    [
      requester,
      request_coordinator,
      request_manager,
      support_coordinator,
      support_manager,
      supporter
    ]
  end

  def user_involved?(user)
    involved_users.include?(user)
  end

  def request_vicedirector
    requester.structure.current_staff_structure["vice_director"]&.user
  end

  def request_coordinator
    requester.structure.current_staff_structure["coordinator"]&.user
  end

  def request_manager
    requester.structure.current_staff_structure["manager"]&.user
  end

  private
    def halve_vicedirector_commission
      unless request_vicedirector == support_vicedirector
        vicedirector_folder_user = folder.folder_users.where(user: request_vicedirector).take
        if vicedirector_folder_user.present?
          vicedirector_percentage = vicedirector_folder_user.percentage
          vicedirector_folder_user.update(percentage: vicedirector_percentage / 2)
        else
          vicedirector_percentage = Role.find_by(key: "vice_director").commission_monitoring_percentage
        end
        folder.folder_users.create(user: support_vicedirector, percentage: vicedirector_percentage / 2, role: support_vicedirector.role, concept: FolderUserConcept.find_by_key(:follow_up))
      end
    end

    def initialize_status
      self.status ||= "creation"
    end

    def notify_request
      SupportSaleMailer.support_notification(folder, request_coordinator, self).deliver_later unless request_coordinator.nil?
      SupportSaleMailer.support_notification(folder, request_manager, self).deliver_later unless request_manager.nil?
    end

    def assign_and_notify_support
      assign_support_user_to_folder(request_manager, support_manager) if was_assigned_support_manager?
      assign_support_user_to_folder(request_coordinator, support_coordinator) if was_assigned_support_coordinator?

      if was_assigned_supporter?
        assign_support_user_to_folder(requester, supporter)

        notify_request_user(requester)
        notify_request_user(request_coordinator)
        notify_request_user(request_manager)
      end
    end

    def assign_support_user_to_folder(initial_user, support_user)
      unless initial_user == support_user
        folder_user = folder.folder_users.where(user: initial_user).take
        if folder_user.present?
          percentage = folder_user.percentage
          folder_user.update(percentage: percentage / 2)
          concept = folder_user.folder_user_concept
        elsif initial_user == folder.user
          percentage = user.role.sale_commission_percentage
          concept = FolderUserConcept.find_by_key(:sale)
        else
          percentage = user.role.commission_monitoring_percentage
          concept = FolderUserConcept.find_by_key(:follow_up)
        end

        folder.folder_users.create!(user: support_user, percentage: percentage / 2, role: support_user.role, folder_user_concept: concept)
      end

      SupportSaleMailer.support_notification(folder, support_user, self).deliver_later
    end

    def notify_request_user(user)
      return if user.nil?

      SupportSaleMailer.support_assigned_notification(user.email, folder, self, supporter.label, support_coordinator.label, support_manager.label).deliver_later
    end

    def notify_reject
      SupportSaleMailer.support_rejected_notification(
        request_manager.email,
        request_manager.label,
        User.find(previous_changes[:support_manager_id].first).label,
        requester.label,
        self
      ).deliver_later
    end

    def revert_folder_commission(user)
      return if user.nil?

      folder_user = folder.folder_users.where(user: user).take
      if folder_user.present?
        folder_user.percentage = folder_user.percentage * 2
        folder_user.save
      end
    end

    def was_rejected
      self.previous_changes.has_key?("status") && self.rejected?
    end

    def was_canceled
      self.previous_changes.has_key?("status") && self.canceled?
    end

    def was_rejected_or_canceled
      was_rejected || was_canceled
    end

    def set_review_status
      self.status = "support_review"
    end

    def support_manager_assigned
      support_manager_id_changed?(from: nil) || (support_manager_id_changed? && rejected?)
    end

    def set_approved_status
      self.status = "approved"
    end

    def supporter_selected
      supporter_id_changed?(from: nil)
    end

    def reject_or_cancel_revertions
      if self.status_changed?(to: "rejected") || self.status_changed?(to: "canceled")
        folder_users = folder.folder_users
        if supporter.present?
          folder_users.where(user: supporter).take.destroy if supporter.present?
          revert_folder_commission(requester)
        end

        if support_coordinator.present? && support_coordinator != supporter
          folder_users.where(user: support_coordinator).take.destroy if support_coordinator.present?
          revert_folder_commission(request_coordinator)
        end

        if support_manager.present?
          folder_users.where(user: support_manager).take.destroy if support_manager.present?
          revert_folder_commission(request_manager)
        end

        if (support_vicedirector.present? && support_vicedirector != request_vicedirector) && self.status_changed?(to: "canceled")
          folder_users.where(user: support_vicedirector).take.destroy if support_vicedirector.present?
          revert_folder_commission(request_vicedirector)
        end

        self.support_manager = nil
        self.support_coordinator = nil
        self.supporter = nil
      end
    end

    def was_assigned_support_manager?
      return false unless self.previous_changes.has_key? :support_manager_id
      changed_support_manager = self.previous_changes["support_manager_id"]
      changed_support_manager.first.nil? && changed_support_manager.second.present?
    end

    def was_assigned_support_coordinator?
      return false unless self.previous_changes.has_key? :support_coordinator_id
      changed_support_coordinator = self.previous_changes["support_coordinator_id"]
      changed_support_coordinator.first.nil? && changed_support_coordinator.second.present?
    end

    def was_assigned_supporter?
      return false unless self.previous_changes.has_key? :supporter_id
      changed_supporter = self.previous_changes["supporter_id"]
      changed_supporter.first.nil? && changed_supporter.second.present?
    end
end
