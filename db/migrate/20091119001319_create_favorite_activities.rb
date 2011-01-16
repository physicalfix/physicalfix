class CreateFavoriteActivities < ActiveRecord::Migration
  def self.up
    create_table :favorite_activities do |t|
      t.references :user, :activity
      t.timestamps
    end
  end

  def self.down
    drop_table :favorite_activities
  end
end
