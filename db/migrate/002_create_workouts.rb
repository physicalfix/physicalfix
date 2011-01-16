class CreateWorkouts < ActiveRecord::Migration
  def self.up
    create_table :workouts do |t|
      t.column "user_id",        :integer
      t.column "week_of",        :date
      t.column "approved",       :boolean, :default => false
      t.column "comment",        :string
      t.column "repeat_count",   :integer, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :workouts
  end
end
