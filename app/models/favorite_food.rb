class FavoriteFood < ActiveRecord::Base
  belongs_to :user
  has_many :food_items, :dependent => :destroy
end