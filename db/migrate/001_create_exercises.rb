class CreateExercises < ActiveRecord::Migration
  def self.up
    create_table :exercises do |t|
      t.column "name",           :string,   :null => false
      t.column "description",    :string
      t.column "musclegroup_id", :integer,  :null => false
    end
  end

  def self.down
    drop_table :exercises
  end
end
