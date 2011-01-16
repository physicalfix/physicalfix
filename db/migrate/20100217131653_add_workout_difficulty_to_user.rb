class AddWorkoutDifficultyToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :workout_difficulty, :string
  end

  def self.down
    remove_column :users, :workout_difficulty
  end
end
