class CreateAnnouncements < ActiveRecord::Migration[5.2]
  def change
    create_table :announcements do |t|
      t.string :title
      t.string :body
      t.datetime :show_at
      t.datetime :expire_at

      t.timestamps
    end
  end
end
