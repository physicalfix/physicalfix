class FoodItem < ActiveRecord::Base
  belongs_to :favorite_food
  belongs_to :user
end