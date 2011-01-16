class CreateExercisesWorkoutsJoin < ActiveRecord::Migration
  def self.up
      create_table :exercises_workouts do |t|
        t.column "exercise_id", :integer, :null => false
        t.column "exercise_clip_id",   :integer
        t.column "workout_id",    :integer, :null => false
        t.column "display_order", :integer, :default => '99999'
        t.column "weight",        :string
        t.column "delay_time",    :integer, :default => 5
      end
  end

  def self.down
    drop_table :exercises_workouts
  end
end
