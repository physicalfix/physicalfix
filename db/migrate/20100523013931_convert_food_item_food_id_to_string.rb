class ConvertFoodItemFoodIdToString < ActiveRecord::Migration
  def self.up
    change_column :food_items, :food_id, :string
  end

  def self.down
    change_column :food_items, :food_id, :string
  end
end
