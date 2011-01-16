class AddLastplayedToWorkoutSessions < ActiveRecord::Migration
  def self.up
     add_column :workout_sessions, :last_played, :integer
     add_column :workout_sessions, :complete, :boolean
  end

  def self.down
    remove_column :workout_sessions, :last_played
    remove_column :workout_sessions, :complete
  end
end
