class AddWorkoutSkeletonIdToWorkout < ActiveRecord::Migration
  def self.up
    add_column :workouts, :workout_skeleton_id, :integer
  end

  def self.down
    remove_column :workouts, :workout_skeleton_id
  end
end
