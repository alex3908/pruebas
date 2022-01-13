# frozen_string_literal: true

class ReplaceJoinTableUsersAnnouncements < ActiveRecord::Migration[5.2]
  def change
    drop_join_table :users, :announcements
    create_table :user_announcements do |t|
      t.belongs_to :user, index: true
      t.belongs_to :announcement, index: true
    end
  end
end
