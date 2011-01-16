class AddMealIdToFoodItems < ActiveRecord::Migration
  def self.up
    add_column  :food_items, :meal_id, :integer
    add_index   :food_items, :meal_id
  end

  def self.down
    remove_index  :food_items, :meal_id
    remove_column :food_items, :meal_id
  end
end
