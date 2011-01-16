class CreateWorkoutSkeletons < ActiveRecord::Migration
  def self.up
    create_table :workout_skeletons do |t|
      t.references :user_bucket
      t.string :name
      t.string :description
      t.timestamps
    end
    add_index :workout_skeletons, :user_bucket_id
  end

  def self.down
    remove_index :workout_skeletons, :user_bucket_id
    drop_table :workout_skeletons
  end
end
