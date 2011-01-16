class CreateMeals < ActiveRecord::Migration
  def self.up
    create_table :meals do |t|
      t.references :user
      t.integer :food_id, :serving_id, :servings
      t.string :food_name, :food_type, :serving_description, :brand_name
      t.float :serving_amount, :calories, :carbohydrate, :protein, :fat, :saturated_fat, :polyunsaturated_fat, 
              :monosaturated_fat, :trans_fat, :cholesterol, :sodium, :potassium, :fiber, :sugar, :vitamin_a, 
              :vitamin_c, :calcium, :iron
      t.string :meal_name
      t.datetime :eaten_at
      t.timestamps
    end
  end

  def self.down
    drop_table :meals
  end
end
