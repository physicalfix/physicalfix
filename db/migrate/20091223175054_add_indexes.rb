class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :email #for login
    add_index :medical_histories, :user_id
    add_index :user_roles, :user_id
    add_index :workouts, :user_id
    add_index :workouts, :week_of
    add_index :meals, :user_id
    add_index :meals, :eaten_at
    add_index :user_weights, :user_id
    add_index :favorite_foods, :user_id
    add_index :user_activities, :user_id
    add_index :user_activities, :activity_date
    add_index :favorite_activities, :activity_id
    add_index :favorite_activities, :user_id
    add_index :user_weights, :created_at
    add_index :workout_sessions, :workout_id
    add_index :exercises, :musclegroup_id
    add_index :exercises_workouts, :workout_id
    add_index :exercises_workouts, :display_order
    add_index :exercise_clips, :exercise_id
  end

  def self.down
    remove_index :users, :email
    remove_index :medical_histories, :user_id
    remove_index :user_roles, :user_id
    remove_index :workouts, :user_id
    remove_index :workouts, :week_of
    remove_index :meals, :user_id
    remove_index :meals, :eaten_at
    remove_index :user_weights, :user_id
    remove_index :favorite_foods, :user_id
    remove_index :user_activities, :user_id
    remove_index :user_activities, :activity_date
    remove_index :favorite_activities, :activity_id
    remove_index :favorite_activities, :user_id
    remove_index :user_weights, :user_id
    remove_index :user_weights, :created_at
    remove_index :workout_sessions, :workout_id
    remove_index :exercises, :musclegroup_id
    remove_index :exercises_workouts, :workout_id
    remove_index :exercises_workouts, :display_order
    remove_index :exercise_clips, :exercise_id
  end
end
