class CreateExerciseClips < ActiveRecord::Migration
  def self.up
    create_table :exercise_clips do |t|
      t.references :exercise
      t.string :clip_file_name, :clip_content_type, :reps
      t.integer :clip_file_size, :seconds
      t.timestamps
    end
  end

  def self.down
    drop_table :exercise_clips
  end
end
