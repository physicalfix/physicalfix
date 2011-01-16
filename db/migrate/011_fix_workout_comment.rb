class FixWorkoutComment < ActiveRecord::Migration
  def self.up
    change_column :workouts, :comment, :text
  end

  def self.down
    change_column :workouts, :comment, :string
  end
end
