class CreateMusclegroups < ActiveRecord::Migration
  def self.up
    create_table :musclegroups do |t|
      t.column :name, :string
    end
    
    Musclegroup.create( :name => 'Chest' )
    Musclegroup.create( :name => 'Back' )
    Musclegroup.create( :name => 'Shoulders' )
    Musclegroup.create( :name => 'Biceps' )
    Musclegroup.create( :name => 'Triceps' )
    Musclegroup.create( :name => 'Legs' )
    Musclegroup.create( :name => 'Abs' )
    Musclegroup.create( :name => 'Core' )
    Musclegroup.create( :name => 'Power' )
    Musclegroup.create( :name => 'Cardio' )
  end

  def self.down
    drop_table :musclegroups
  end
end
