class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :name
      t.float :calories_burned_per_pound_per_minute
      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
