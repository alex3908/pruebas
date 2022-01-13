class CreateUsersAnnouncementsJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :users, :announcements do |t|
      t.index :user_id
      t.index :announcement_id
    end
  end
end
