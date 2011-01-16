class CreateFoodItems < ActiveRecord::Migration
  def self.up
    create_table :food_items do |t|
      t.references :favorite_food, :user
      t.integer :food_id, :serving_id, :servings
      t.timestamps
    end
  end

  def self.down
    drop_table :food_items
  end
end
