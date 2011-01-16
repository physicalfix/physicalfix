class AddNotesToWorkout < ActiveRecord::Migration
  def self.up
    add_column :workouts, :note, :text
  end

  def self.down
    remove_column :workouts, :note
  end
end
