class CreateWorkoutSkeletonMusclegroups < ActiveRecord::Migration
  def self.up
    create_table :workout_skeleton_musclegroups do |t|
      t.references :workout_skeleton
      t.references :musclegroup
      t.integer :display_order, :default => '99999'
      t.timestamps
    end
    add_index :workout_skeleton_musclegroups, :workout_skeleton_id
    add_index :workout_skeleton_musclegroups, :musclegroup_id
  end

  def self.down
    remove_index :workout_skeleton_musclegroups, :musclegroup_id
    remove_index :workout_skeleton_musclegroups, :workout_skeleton_id
    drop_table :workout_skeleton_musclegroups
  end
end
