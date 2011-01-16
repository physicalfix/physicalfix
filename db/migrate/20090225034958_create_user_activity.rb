class CreateUserActivity < ActiveRecord::Migration
  def self.up
    create_table :user_activities do |t|
      t.references :user, :activity
      t.string :name
      t.float :duration, :calories_burned
      t.datetime :activity_date
      t.timestamps
    end
  end

  def self.down
    drop_table :user_activities
  end
end
