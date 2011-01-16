class ConvertMealsFoodIdToString < ActiveRecord::Migration
  def self.up
    change_column :meals, :food_id, :string
  end

  def self.down
    change_column :meals, :food_id, :string
  end
end
