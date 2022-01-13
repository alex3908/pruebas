# frozen_string_literal: true

class Announcement < ApplicationRecord
  has_many :user_announcements
  has_many :users, through: :user_announcements

  def self.global
    left_outer_joins(:users)
      .where("user_announcements.user_id IS NULL")
  end

  def self.now_showing
    where("show_at < ? OR show_at IS NULL", Time.zone.now)
  end

  def self.not_expired
    where("expire_at > ?", Time.zone.now)
  end

  def self.for_user(user)
    left_outer_joins(:users)
      .where("user_announcements.user_id = ?", user.id)
      .now_showing
      .not_expired
  end
end
