# frozen_string_literal: true

module FolderActionsConcern
  extend ActiveSupport::Concern

  included do
    attr_accessor :action
  end

  def expire
    self.action = :expire
    update(status: "expired", step: nil)
  end

  def expire!
    self.action = :expire
    update!(status: "expired", step: nil)
  end

  def cancel(description)
    self.action = :cancel
    update(
      status: Folder::STATUS[:CANCELED],
      canceled_description: description,
      canceled_date: Time.zone.now,
      canceled_by: Current.user,
      step: nil,
    )
  end

  def cancel!(description)
    self.action = :cancel
    update!(
      status: Folder::STATUS[:CANCELED],
      canceled_description: description,
      canceled_date: Time.zone.now,
      canceled_by: Current.user,
      step: nil,
    )
  end

  def reactivate
    self.action = :reactivate
    update(status: Folder::STATUS[:ACTIVE], step: Step.first_step)
  end

  def reactivate!
    self.action = :reactivate
    update!(status: Folder::STATUS[:ACTIVE], step: Step.first_step)
  end

  def approve
    self.action = :approve
    update(step: step.next_step) if !finished?
  end

  def approve!
    self.action = :approve
    update!(step: step.next_step) if !finished?
  end

  def move_back
    self.action = :soft_reject
    update(step: step.prev_step) if !fresh?
  end

  def move_back!
    self.action = :soft_reject
    update!(step: step.prev_step) if !fresh?
  end

  def reject
    self.action = :refuse
    update(step: step.reject_step) if !fresh?
  end

  def reject!
    self.action = :refuse
    update!(step: step.reject_step) if !fresh?
  end

  def fresh?
    active? && step.is_first_one?
  end

  def under_revision?
    active? && !step.is_first_one? && !step.is_last_one?
  end

  def finished?
    active? && step.is_last_one?
  end
end
