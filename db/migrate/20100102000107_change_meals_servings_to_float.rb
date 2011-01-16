class ChangeMealsServingsToFloat < ActiveRecord::Migration
  def self.up
    change_column :meals, :servings, :float
  end

  def self.down
    change_column :meals, :servings, :integer
  end
end
