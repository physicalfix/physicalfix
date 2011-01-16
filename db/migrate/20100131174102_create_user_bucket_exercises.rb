class CreateUserBucketExercises < ActiveRecord::Migration
  def self.up
    create_table :user_bucket_exercises do |t|
      t.references :user_bucket
      t.references :exercise
      t.timestamps
    end
    add_index :user_bucket_exercises, :user_bucket_id
    add_index :user_bucket_exercises, :exercise_id
  end

  def self.down
    remove_index :user_bucket_exercises, :exercise_id
    remove_index :user_bucket_exercises, :user_bucket_id
    drop_table :user_bucket_exercises
  end
end
